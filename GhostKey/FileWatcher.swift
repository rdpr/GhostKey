import Foundation


final class FileWatcher {
private var sources: [DispatchSourceFileSystemObject] = []
private let callback: () -> Void


init(paths: [String], onChange: @escaping () -> Void) {
self.callback = onChange
for p in paths {
openAndWatch(path: p)
}
}


deinit { sources.forEach { $0.cancel() } }


private func openAndWatch(path: String) {
let fd = open(path, O_EVTONLY)
guard fd >= 0 else { return }
let src = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: [.write, .delete, .rename], queue: .main)
src.setEventHandler { [weak self] in
self?.callback()
}
src.setCancelHandler { close(fd) }
src.resume()
sources.append(src)
}
}
