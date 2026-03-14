//
//  SettingView.swift
//  HowToUseKit
//
//  Created by Moonyoung on 3/14/26.
//

import SwiftUI
import UIKit

// MARK: - SettingView

@MainActor
public struct SettingView: View {
    public var tint: Color
    public var theme: OnBoarding.Theme
    public var title: String
    public var sections: [Section]
    public var footer: Footer?
    public var onDismiss: (() -> Void)?

    public init(
        tint: Color = .blue,
        theme: OnBoarding.Theme = .light,
        title: String = "Settings",
        sections: [Section],
        footer: Footer? = Footer(),
        onDismiss: (() -> Void)? = nil
    ) {
        self.tint = tint
        self.theme = theme
        self.title = title
        self.sections = sections
        self.footer = footer
        self.onDismiss = onDismiss
        _ = registerFontsOnce
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                        SectionView(section: section)
                    }
                    if let footer {
                        FooterView(footer: footer)
                            .padding(.top, 36)
                            .padding(.bottom, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(theme.listBackground)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onDismiss {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 28, height: 28)
                                .background(Color(.systemGray5), in: Circle())
                        }
                    }
                }
            }
        }
        .tint(tint)
        .preferredColorScheme(theme.colorScheme)
    }


    // MARK: - Section View

    @ViewBuilder
    func SectionView(section: Section) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header = section.header {
                Text(header)
                    .font(.custom("Inter18pt-SemiBold", size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 6)
            } else {
                Spacer().frame(height: 20)
            }

            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.offset) { index, item in
                    ItemView(item: item)
                    if index < section.items.count - 1 {
                        Divider()
                            .padding(.leading, item.dividerLeading)
                    }
                }
            }
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)

            if let footer = section.footer {
                Text(footer)
                    .font(.custom("Inter18pt-Regular", size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
            }
        }
    }


    // MARK: - Item View

    @ViewBuilder
    func ItemView(item: Item) -> some View {
        Group {
            switch item.kind {
            case let .toggle(icon, iconColor, title, subtitle, isOn, contextMenu):
                ToggleItemView(icon: icon, iconColor: iconColor,
                               title: title, subtitle: subtitle, isOn: isOn)
                    .contextMenuIfNeeded(contextMenu)

            case let .navigation(icon, iconColor, title, value, style, destination, contextMenu):
                NavigationLink(destination: destination) {
                    NavigationItemContent(icon: icon, iconColor: iconColor,
                                         title: title, value: value, style: style)
                }
                .buttonStyle(.plain)
                .contextMenuIfNeeded(contextMenu)

            case let .link(icon, title, url, tintColor, contextMenu):
                Link(destination: url) {
                    LinkItemContent(icon: icon, title: title, tintColor: tintColor)
                }
                .buttonStyle(.plain)
                .contextMenuIfNeeded(contextMenu)

            case let .action(icon, title, tintColor, action, contextMenu):
                Button(action: action) {
                    ActionItemContent(icon: icon, title: title, tintColor: tintColor)
                }
                .buttonStyle(.plain)
                .contextMenuIfNeeded(contextMenu)

            case let .permission(icon, iconColor, title, subtitle, status, action):
                PermissionItemView(icon: icon, iconColor: iconColor,
                                   title: title, subtitle: subtitle, status: status, action: action)

            case let .subscription(icon, iconColor, title, subtitle, state, destination):
                NavigationLink(destination: destination) {
                    SubscriptionItemContent(icon: icon, iconColor: iconColor,
                                            title: title, subtitle: subtitle,
                                            state: state, tint: tint)
                }
                .buttonStyle(.plain)

            case let .custom(view):
                view
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }


    // MARK: - Toggle Item

    @ViewBuilder
    func ToggleItemView(icon: String?, iconColor: Color?,
                        title: String, subtitle: String?,
                        isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            if let icon, let iconColor {
                IconView(systemName: icon, color: iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Inter18pt-Regular", size: 16))
                    .foregroundStyle(theme.primaryText)
                if let subtitle {
                    Text(subtitle)
                        .font(.custom("Inter18pt-Regular", size: 13))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(tint)
        }
    }


    // MARK: - Navigation Item Content

    @ViewBuilder
    func NavigationItemContent(icon: String?, iconColor: Color?,
                                title: String, value: String?,
                                style: Item.NavigationStyle) -> some View {
        HStack(spacing: 12) {
            if let icon, let iconColor {
                IconView(systemName: icon, color: iconColor)
            } else if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
            }
            Text(title)
                .font(.custom("Inter18pt-Regular", size: 16))
                .foregroundStyle(theme.primaryText)
            Spacer()
            if let value {
                Text(value)
                    .font(.custom("Inter18pt-Regular", size: 15))
                    .foregroundStyle(.secondary)
            }
            switch style {
            case .push:
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.systemGray3))
            case .external:
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.systemGray3))
            }
        }
    }


    // MARK: - Link Item Content

    @ViewBuilder
    func LinkItemContent(icon: String?, title: String, tintColor: Color?) -> some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(tintColor ?? theme.primaryText)
                    .frame(width: 28, height: 28)
            }
            Text(title)
                .font(.custom("Inter18pt-Regular", size: 16))
                .foregroundStyle(tintColor ?? theme.primaryText)
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.systemGray3))
        }
    }


    // MARK: - Action Item Content

    @ViewBuilder
    func ActionItemContent(icon: String?, title: String, tintColor: Color?) -> some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(tintColor ?? theme.primaryText)
                    .frame(width: 28, height: 28)
            }
            Text(title)
                .font(.custom("Inter18pt-Regular", size: 16))
                .foregroundStyle(tintColor ?? theme.primaryText)
            Spacer()
        }
    }


    // MARK: - Permission Item

    @ViewBuilder
    func PermissionItemView(icon: String, iconColor: Color,
                            title: String, subtitle: String,
                            status: Item.PermissionStatus,
                            action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                IconView(systemName: icon, color: iconColor)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.custom("Inter18pt-Regular", size: 16))
                            .foregroundStyle(theme.primaryText)
                        status.badge
                    }
                    Text(subtitle)
                        .font(.custom("Inter18pt-Regular", size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }


    // MARK: - Subscription Item Content

    @ViewBuilder
    func SubscriptionItemContent(icon: String, iconColor: Color,
                                  title: String, subtitle: String,
                                  state: Item.SubscriptionState,
                                  tint: Color) -> some View {
        HStack(spacing: 12) {
            IconView(systemName: icon, color: iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Inter18pt-SemiBold", size: 16))
                    .foregroundStyle(theme.primaryText)
                Text(subtitle)
                    .font(.custom("Inter18pt-Regular", size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            switch state {
            case .notSubscribed(let buttonTitle):
                Text(buttonTitle)
                    .font(.custom("Inter18pt-SemiBold", size: 14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(tint, in: Capsule())
            case .subscribed:
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.green)
                    Text("Active")
                        .font(.custom("Inter18pt-SemiBold", size: 14))
                        .foregroundStyle(.green)
                }
            }
        }
    }


    // MARK: - Footer View

    @ViewBuilder
    func FooterView(footer: Footer) -> some View {
        VStack(spacing: 6) {
            if let icon = footer.resolvedAppIcon {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
            Text(footer.resolvedAppName)
                .font(.custom("Inter18pt-Bold", size: 16))
                .foregroundStyle(theme.primaryText)
            Text("Version \(footer.versionString)")
                .font(.custom("Inter18pt-Regular", size: 13))
                .foregroundStyle(.secondary)
            if let developerName = footer.developerName {
                Text(developerName)
                    .font(.custom("Inter18pt-Regular", size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }


    // MARK: - Icon View

    @ViewBuilder
    func IconView(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(color, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}


// MARK: - Section

extension SettingView {
    public struct Section {
        public var header: String?
        public var footer: String?
        public var items: [Item]

        public init(
            header: String? = nil,
            footer: String? = nil,
            items: [Item]
        ) {
            self.header = header
            self.footer = footer
            self.items = items
        }
    }
}


// MARK: - Item

extension SettingView {
    public struct Item {

        // MARK: Supporting Types

        public enum NavigationStyle {
            case push
            case external
        }

        public enum PermissionStatus {
            case granted
            case denied
            case notDetermined

            @ViewBuilder
            var badge: some View {
                switch self {
                case .granted:
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.green)
                case .denied:
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                case .notDetermined:
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.orange)
                }
            }
        }

        public enum SubscriptionState {
            case notSubscribed(buttonTitle: String = "Upgrade")
            case subscribed(planTitle: String, renewalInfo: String? = nil)
        }

        public struct ContextMenuItem {
            public var title: String
            public var systemImage: String?
            public var role: ButtonRole?
            public var action: () -> Void

            public init(title: String, systemImage: String? = nil,
                        role: ButtonRole? = nil, action: @escaping () -> Void) {
                self.title = title
                self.systemImage = systemImage
                self.role = role
                self.action = action
            }
        }

        // MARK: Kind

        enum Kind {
            case toggle(icon: String?, iconColor: Color?,
                        title: String, subtitle: String?,
                        isOn: Binding<Bool>,
                        contextMenu: [ContextMenuItem])
            case navigation(icon: String?, iconColor: Color?,
                            title: String, value: String?,
                            style: NavigationStyle,
                            destination: AnyView,
                            contextMenu: [ContextMenuItem])
            case link(icon: String?, title: String,
                      url: URL, tintColor: Color?,
                      contextMenu: [ContextMenuItem])
            case action(icon: String?, title: String,
                        tintColor: Color?, action: () -> Void,
                        contextMenu: [ContextMenuItem])
            case permission(icon: String, iconColor: Color,
                            title: String, subtitle: String,
                            status: PermissionStatus,
                            action: (() -> Void)?)
            case subscription(icon: String, iconColor: Color,
                               title: String, subtitle: String,
                               state: SubscriptionState,
                               destination: AnyView)
            case custom(AnyView)
        }

        let kind: Kind

        var dividerLeading: CGFloat {
            switch kind {
            case .toggle(let icon, let iconColor, _, _, _, _):
                return (icon != nil && iconColor != nil) ? 58 : 16
            case .navigation(let icon, let iconColor, _, _, _, _, _):
                return (icon != nil && iconColor != nil) ? 58 : 16
            case .subscription: return 58
            case .permission: return 58
            default: return 16
            }
        }


        // MARK: Factory Methods

        public static func toggle(
            icon: String? = nil,
            iconColor: Color? = nil,
            title: String,
            subtitle: String? = nil,
            isOn: Binding<Bool>,
            contextMenu: [ContextMenuItem] = []
        ) -> Item {
            Item(kind: .toggle(icon: icon, iconColor: iconColor,
                               title: title, subtitle: subtitle,
                               isOn: isOn, contextMenu: contextMenu))
        }

        public static func navigation<Destination: View>(
            icon: String? = nil,
            iconColor: Color? = nil,
            title: String,
            value: String? = nil,
            style: NavigationStyle = .push,
            contextMenu: [ContextMenuItem] = [],
            @ViewBuilder destination: () -> Destination
        ) -> Item {
            Item(kind: .navigation(icon: icon, iconColor: iconColor,
                                   title: title, value: value,
                                   style: style,
                                   destination: AnyView(destination()),
                                   contextMenu: contextMenu))
        }

        public static func link(
            icon: String? = nil,
            title: String,
            url: URL,
            tintColor: Color? = nil,
            contextMenu: [ContextMenuItem] = []
        ) -> Item {
            Item(kind: .link(icon: icon, title: title,
                             url: url, tintColor: tintColor,
                             contextMenu: contextMenu))
        }

        public static func action(
            icon: String? = nil,
            title: String,
            tintColor: Color? = nil,
            contextMenu: [ContextMenuItem] = [],
            action: @escaping () -> Void
        ) -> Item {
            Item(kind: .action(icon: icon, title: title,
                               tintColor: tintColor, action: action,
                               contextMenu: contextMenu))
        }

        public static func permission(
            icon: String,
            iconColor: Color,
            title: String,
            subtitle: String,
            status: PermissionStatus,
            action: (() -> Void)? = nil
        ) -> Item {
            Item(kind: .permission(icon: icon, iconColor: iconColor,
                                   title: title, subtitle: subtitle,
                                   status: status, action: action))
        }

        public static func subscription<Destination: View>(
            icon: String = "crown.fill",
            iconColor: Color = .orange,
            title: String,
            subtitle: String,
            state: SubscriptionState,
            @ViewBuilder destination: () -> Destination
        ) -> Item {
            Item(kind: .subscription(icon: icon, iconColor: iconColor,
                                     title: title, subtitle: subtitle,
                                     state: state,
                                     destination: AnyView(destination())))
        }

        public static func custom<Content: View>(
            @ViewBuilder content: () -> Content
        ) -> Item {
            Item(kind: .custom(AnyView(content())))
        }
    }
}


// MARK: - Footer

extension SettingView {
    public struct Footer {
        public var appIcon: UIImage?
        public var appName: String?
        public var developerName: String?

        public init(
            appIcon: UIImage? = nil,
            appName: String? = nil,
            developerName: String? = nil
        ) {
            self.appIcon = appIcon
            self.appName = appName
            self.developerName = developerName
        }

        var resolvedAppName: String {
            appName
                ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? "App"
        }

        var resolvedAppIcon: UIImage? {
            if let appIcon { return appIcon }
            guard
                let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
                let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
                let files = primary["CFBundleIconFiles"] as? [String],
                let last = files.last
            else { return nil }
            return UIImage(named: last)
        }

        var versionString: String {
            let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
            return "\(short) (\(build))"
        }
    }
}


// MARK: - Theme Extension

extension OnBoarding.Theme {
    var listBackground: Color {
        switch self {
        case .dark: return Color(.systemBackground)
        case .light: return Color(.systemGroupedBackground)
        }
    }

    var cardBackground: Color {
        switch self {
        case .dark: return Color(.secondarySystemBackground)
        case .light: return Color(.secondarySystemGroupedBackground)
        }
    }
}


// MARK: - ContextMenu Helper

private extension View {
    @ViewBuilder
    func contextMenuIfNeeded(_ items: [SettingView.Item.ContextMenuItem]) -> some View {
        if items.isEmpty {
            self
        } else {
            self.contextMenu {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    if let systemImage = item.systemImage {
                        Button(role: item.role) {
                            item.action()
                        } label: {
                            Label(item.title, systemImage: systemImage)
                        }
                    } else {
                        Button(item.title, role: item.role) {
                            item.action()
                        }
                    }
                }
            }
        }
    }
}
