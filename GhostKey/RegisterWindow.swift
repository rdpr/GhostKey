import SwiftUI

struct ManageCodesView: View {
    @State private var input = ""
    @State private var codes: [String] = []
    @State private var validationError: ValidationError? = nil
    @State private var showSuccess = false
    @State private var previousCodeCount = 0
    @State private var thresholds = Preferences.thresholds
    private let store = CodeStore()
    private let refreshTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with counter
            counterHeader()
            
            Divider()
            
            // Main content - single ScrollView only for the top section
            VStack(spacing: 0) {
                // Add new code section (not scrollable)
                VStack(spacing: 20) {
                    addCodeSection()
                    
                    Divider()
                        .padding(.horizontal, 20)
                }
                .padding(20)
                
                // Codes list section (scrollable)
                codesListSection()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .frame(width: 580, height: 520)
        .onAppear {
            refreshCodes()
            previousCodeCount = codes.count
        }
        .onReceive(refreshTimer) { _ in
            refreshCodes()
        }
        .onReceive(NotificationCenter.default.publisher(for: .YCPreferencesSaved)) { _ in
            // Update thresholds when preferences change
            thresholds = Preferences.thresholds
        }
    }
    
    // MARK: - Counter Header
    
    private func counterHeader() -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Color indicator
                let remaining = codes.count
                let band = ColorBand.from(remaining: remaining)
                
                Image(band.imageName)
                    .resizable()
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(remaining) codes remaining")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text(statusMessage(for: band))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Threshold info
            HStack(spacing: 16) {
                thresholdBadge(imageName: "GreenGhost", label: ">\(thresholds.yellow)")
                thresholdBadge(imageName: "YellowGhost", label: "≤\(thresholds.yellow)")
                thresholdBadge(imageName: "OrangeGhost", label: "≤\(thresholds.orange)")
                thresholdBadge(imageName: "RedGhost", label: "≤\(thresholds.red)")
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func thresholdBadge(imageName: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(imageName)
                .resizable()
                .frame(width: 12, height: 12)
            Text(label)
        }
    }
    
    private func statusMessage(for band: ColorBand) -> String {
        switch band {
        case .green: return "You have plenty of codes"
        case .yellow: return "Getting low - consider adding more"
        case .orange: return "Running out - add more soon"
        case .red: return "Critical - add codes now!"
        }
    }
    
    // MARK: - Add Code Section
    
    private func addCodeSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add New Code")
                .font(.system(size: 15, weight: .semibold))
            
            Text("Press your YubiKey or type a code (6–10 digits)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Enter code...", text: $input)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .onSubmit {
                            if !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                addCode()
                            }
                        }
                        .onChange(of: input) { _ in
                            validationError = nil
                            showSuccess = false
                            validateInput()
                        }
                    
                    // Fixed height container for validation/success messages
                    Group {
                        if let error = validationError {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 11))
                                Text(error.message)
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.red)
                        } else if showSuccess {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 11))
                                Text("Code added successfully!")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.green)
                        } else {
                            Text(" ")
                                .font(.system(size: 11))
                        }
                    }
                    .frame(height: 16)
                }
                
                Button("Add") {
                    addCode()
                }
                .buttonStyle(.borderedProminent)
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || validationError != nil)
                .keyboardShortcut(.defaultAction)
            }
        }
    }
    
    // MARK: - Codes List Section
    
    private func codesListSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Codes")
                .font(.system(size: 15, weight: .semibold))
            
            if codes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No codes yet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("Add your first code above to get started")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(codes.enumerated()), id: \.offset) { index, code in
                                HStack {
                                    Text("#\(index + 1)")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .frame(width: 40, alignment: .trailing)
                                    
                                    Text(code)
                                        .font(.system(size: 14, design: .monospaced))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        deleteCode(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Remove this code")
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(index % 2 == 0 ? Color(NSColor.controlBackgroundColor) : Color.clear)
                                .id(index)
                            }
                        }
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                    .frame(maxHeight: .infinity)
                    .onChange(of: codes.count) { newCount in
                        // Only scroll to bottom when codes are added (not deleted)
                        if newCount > previousCodeCount && newCount > 0 {
                            withAnimation {
                                proxy.scrollTo(newCount - 1, anchor: .bottom)
                            }
                        }
                        previousCodeCount = newCount
                    }
                }
            }
        }
    }
    
    // MARK: - Validation
    
    private func validateInput() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            validationError = nil
            return
        }
        
        // Check if it's only digits
        guard trimmed.range(of: "^\\d+$", options: .regularExpression) != nil else {
            validationError = ValidationError(message: "Code must contain only digits")
            return
        }
        
        // Check length
        if trimmed.count < 6 {
            validationError = ValidationError(message: "Code must be at least 6 digits")
            return
        }
        
        if trimmed.count > 10 {
            validationError = ValidationError(message: "Code must be at most 10 digits")
            return
        }
        
        validationError = nil
    }
    
    // MARK: - Actions
    
    private func addCode() {
        validateInput()
        
        guard validationError == nil else { return }
        
        do {
            try store.append(code: input)
            input = ""
            validationError = nil
            showSuccess = true
            refreshCodes()
            
            // Hide success message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSuccess = false
            }
        } catch {
            validationError = ValidationError(message: error.localizedDescription)
        }
    }
    
    private func refreshCodes() {
        store.loadAll()
        codes = store.codes
    }
    
    private func deleteCode(at index: Int) {
        // Remove from array
        codes.remove(at: index)
        
        // Write updated codes back to file
        do {
            let content = codes.joined(separator: "\n") + (codes.isEmpty ? "" : "\n")
            let data = content.data(using: .utf8) ?? Data()
            try atomicWrite(data: data, to: Preferences.codesURL)
            
            // Refresh to ensure consistency
            refreshCodes()
        } catch {
            NSLog("Failed to delete code: \(error)")
            // Revert on error
            refreshCodes()
        }
    }
}

struct ValidationError: Identifiable {
    let id = UUID()
    let message: String
}

enum ManageCodesWindow {
    private static var window: NSWindow?
    private static var windowDelegate: ManageCodesWindowDelegate?

    static func show() {
        if window == nil {
            let hosting = NSHostingView(rootView: ManageCodesView())
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 560),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            w.center()
            w.title = "GhostKey"
            w.isReleasedWhenClosed = false
            w.contentView = hosting
            
            // Set up delegate to handle window close
            windowDelegate = ManageCodesWindowDelegate()
            w.delegate = windowDelegate
            
            window = w
        }
        
        // Show in dock when this window opens
        NSApp.setActivationPolicy(.regular)
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    static func close() {
        window?.close()
    }
    
    static func handleWindowClose() {
        window = nil
        windowDelegate = nil
        
        // Hide from dock when window closes
        NSApp.setActivationPolicy(.accessory)
    }
}

class ManageCodesWindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        ManageCodesWindow.handleWindowClose()
    }
}

// Backward compatibility - keep RegisterWindow as alias
typealias RegisterWindow = ManageCodesWindow
