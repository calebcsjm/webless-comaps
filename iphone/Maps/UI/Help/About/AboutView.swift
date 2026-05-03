import SwiftUI

/// View for the about information
struct AboutView: View {
    // MARK: Properties

    /// The dismiss action of the environment
    @Environment(\.dismiss) private var dismiss


    /// The app name
    private var appName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }


    /// The app version
    private var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }


    /// The app build number
    private var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }


    /// The information to copy when long pressing the version number
    private var copyInformation: String? {
        if let appVersion, let appBuild {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyMMdd"
            if let date = dateFormatter.date(from: String(FrameworkHelper.dataVersion())) {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                return String(localized: "version: \(appVersion) (\(appBuild))\nmap data: \(dateFormatter.string(from: date))")
            }
        }

        return nil
    }


    /// The actual view
    var body: some View {
        NavigationView {
            List {
                Section {
                    if #available(iOS 16, *) {
                        AboutCoMapsView()
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            return 0
                        }
                    } else {
                        AboutCoMapsView()
                    }

                    NavigationLink {
                        FaqView()
                    } label: {
                        Label("faq", systemImage: "questionmark.circle")
                            .foregroundStyle(.alternativeAccent)
                    }
                    .tint(.alternativeAccent)

                    Button {
                        MailComposer.sendBugReportWith(title: "Bug Report")
                    } label: {
                        Label("report_a_bug", systemImage: "exclamationmark.bubble")
                    }
                    .tint(.alternativeAccent)
                }

                Section {
                    if #available(iOS 16, *) {
                        ApoutOpenStreetMapView()
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            return 0
                        }
                    } else {
                        ApoutOpenStreetMapView()
                    }
                } footer: {
                    VStack(spacing: 8) {
                        NavigationLink {
                            CopyrightView()
                        } label: {
                            Text("copyright")
                        }

                        Text("Built on CoMaps — based on Organic Maps and OpenStreetMap data.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .tint(.secondary)
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                }
            }
            .accentColor(.accent)
            .navigationTitle(appName ?? String())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        Button {
                            if let copyInformation {
                                UIPasteboard.general.string = copyInformation
                            }
                        } label: {
                            Label("copy_to_clipboard", systemImage: "document.on.clipboard")
                        }
                    } label: {
                        VStack {
                            if let appName {
                                Text(appName)
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .foregroundStyle(.white.opacity(0.96))
                            }

                            if let appVersion, let appBuild {
                                Text("version \(appVersion) (\(appBuild))")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.92))
                            }
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26, *) {
                        Button {
                            dismiss()
                        } label: {
                            Label("close", systemImage: "xmark")
                        }
                        .buttonStyle(.glassProminent)
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("close")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.toolbarAccent)
    }
}
