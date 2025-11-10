import Foundation

final class FileWatcher {
    private struct Watched { let path: String; let fd: Int32; let src: DispatchSourceFileSystemObject }
    private var watched: [Watched] = []
    private let callback: () -> Void

    init(paths: [String], onChange: @escaping () -> Void) {
        self.callback = onChange
        for p in paths { addWatch(path: p) }
    }

    deinit { watched.forEach { $0.src.cancel() } }

    func updatePaths(_ paths: [String]) {
        // Rebuild all watchers
        watched.forEach { $0.src.cancel() }
        watched.removeAll()
        for p in paths { addWatch(path: p) }
    }

    private func addWatch(path: String) {
        let fd = open(path, O_EVTONLY)
        guard fd >= 0 else { return }
        let src = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: [.write, .delete, .rename], queue: .main)
        // Debounce bursts
        var pending = false
        src.setEventHandler { [weak self] in
            guard let self = self else { return }
            if src.data.contains(.delete) || src.data.contains(.rename) {
                // File editors often save via rename; rebind watcher to the new inode
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.rebind(path: path)
                    self.callback()
                }
                return
            }
            if !pending {
                pending = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    pending = false
                    self.callback()
                }
            }
        }
        src.setCancelHandler { close(fd) }
        src.resume()
        watched.append(Watched(path: path, fd: fd, src: src))
    }

    private func rebind(path: String) {
        // Remove existing watcher for path and add again
        if let idx = watched.firstIndex(where: { $0.path == path }) {
            watched[idx].src.cancel()
            watched.remove(at: idx)
        }
        addWatch(path: path)
    }
}