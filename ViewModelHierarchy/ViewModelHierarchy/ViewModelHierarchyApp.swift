//
//  ViewModelHierarchyApp.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

@main
struct ViewModelHierarchyApp: App {
    // If you use AppDelegate, attach rootViewModel to that.
    @State private var rootViewModel = RootCoordinatorView.ViewModel()

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView(viewModel: rootViewModel)
                .onOpenURL { url in
                    guard let path = AppPath(from: url) else {
                        return
                    }

                    rootViewModel.handle(path)
                }
        }
    }
}

// MARK: Deep Linking

enum AppPath {
    enum RootPath {
        enum MainPath {
            enum HomePath {
                case home
                case profile
            }

            enum MorePath {
                case more
                case details
            }

            case home(HomePath)
            case more(MorePath)
            case settings
        }

        case about
        case main(MainPath)
    }

    case root(RootPath)
}

extension AppPath {
    init?(from url: URL) {
        var pathComponents = url.pathComponents.dropFirst()

        guard pathComponents.first == "app" else {
            return nil
        }

        pathComponents = pathComponents.dropFirst()

        switch pathComponents.first {
            case "root":
                if let path = Self.RootPath(from: [String](pathComponents.dropFirst())) {
                    self = .root(path)
                } else {
                    return nil
                }
            default:
                return nil
        }
    }

    var rootPath: RootPath {
        switch self {
            case .root(let path):
                return path
        }
    }
}

extension AppPath.RootPath {
    init?(from pathComponents: [String]) {
        switch pathComponents.first {
            case "about":
                self = .about
            case "main":
                if let path = Self.MainPath(from: [String](pathComponents.dropFirst())) {
                    self = .main(path)
                } else {
                    return nil
                }
            default:
                return nil
        }
    }

    var aboutPath: Bool {
        guard case .about = self else {
            return false
        }
        return true
    }

    var rootPath: MainPath? {
        guard case .main(let path) = self else {
            return nil
        }
        return path
    }
}

extension AppPath.RootPath.MainPath {
    init?(from pathComponents: [String]) {
        switch pathComponents.first {
            case "home":
                if let path = Self.HomePath(from: [String](pathComponents.dropFirst())) {
                    self = .home(path)
                } else {
                    return nil
                }
            case "more":
                if let path = Self.MorePath(from: [String](pathComponents.dropFirst())) {
                    self = .more(path)
                } else {
                    return nil
                }
            case "settings":
                self = .settings
            default:
                return nil
        }
    }

    var homePath: HomePath? {
        guard case .home(let path) = self else {
            return nil
        }
        return path
    }

    var morePath: MorePath? {
        guard case .more(let path) = self else {
            return nil
        }
        return path
    }

    var settingsPath: Bool {
        guard case .settings = self else {
            return false
        }
        return true
    }
}

extension AppPath.RootPath.MainPath.HomePath {
    init?(from pathComponents: [String]) {
        switch pathComponents.first {
            case "home":
                self = .home
            case "profile":
                self = .profile
            default:
                return nil
        }
    }

    var homePath: Bool {
        guard case .home = self else {
            return false
        }
        return true
    }

    var profilePath: Bool {
        guard case .profile = self else {
            return false
        }
        return true
    }
}

extension AppPath.RootPath.MainPath.MorePath {
    init?(from pathComponents: [String]) {
        switch pathComponents.first {
            case "more":
                self = .more
            case "details":
                self = .details
            default:
                return nil
        }
    }

    var morePath: Bool {
        guard case .more = self else {
            return false
        }
        return true
    }

    var detailsPath: Bool {
        guard case .details = self else {
            return false
        }
        return true
    }
}
