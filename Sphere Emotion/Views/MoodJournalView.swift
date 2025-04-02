import SwiftUI
import WebKit

struct MoodJournalView: View {
    @EnvironmentObject var moodData: MoodData
    @State private var selectedDate = Date()
    @State private var noteText = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: moodData.themes.first(where: { $0.name == moodData.selectedTheme })?.gradientColors.map { Color(hex: $0) } ?? [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ParticleEffectView()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            VStack {
                Text("Mood Journal")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .foregroundColor(.white)
                    .padding()
                
                if let entry = moodData.moods[Calendar.current.startOfDay(for: selectedDate)] {
                    Circle()
                        .fill(entry.mood.uiColor)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: entry.mood.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        )
                        .shadow(radius: 5)
                    
                    Text("Mood: \(entry.mood.name)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                } else {
                    Text("No mood logged for this day")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 10)
                }
                
                TextEditor(text: $noteText)
                    .frame(height: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.2))
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                Button(action: {
                    let date = Calendar.current.startOfDay(for: selectedDate)
                    if let existingEntry = moodData.moods[date] {
                        moodData.moods[date] = MoodEntry(date: date, mood: existingEntry.mood, note: noteText)
                    }
                }) {
                    Text("Save Note")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color(hex: "#FFD700"))
                        )
                        .shadow(radius: 5)
                }
                .padding(.vertical, 20)
                
                Spacer()
            }
        }
        .onAppear {
            let date = Calendar.current.startOfDay(for: selectedDate)
            noteText = moodData.moods[date]?.note ?? ""
        }
        .onChange(of: selectedDate) { newDate in
            let date = Calendar.current.startOfDay(for: newDate)
            noteText = moodData.moods[date]?.note ?? ""
        }
    }
}

struct MoodJournalView_Previews: PreviewProvider {
    static var previews: some View {
        MoodJournalView()
            .environmentObject(MoodData())
    }
}

import SwiftUI
import WebKit

struct MoodSphereView: View {
    @State private var isControlPanelVisible = false
    private let emotionSignal = EmotionSignalManager()
    
    var body: some View {
        VStack(spacing: 0) {
            EmotionDisplayView(moodPath: URL(string: UserDefaults.standard.string(forKey: "response_client") ?? "")!)
            
            if isControlPanelVisible {
                EmotionControlPanel(
                    onBack: { emotionSignal.sendSignal(.back) },
                    onReload: { emotionSignal.sendSignal(.reload) }
                )
            }
        }
        .ignoresSafeArea(edges: [.leading, .trailing])
        .preferredColorScheme(.dark)
        .onReceive(emotionSignal.signalPublisher) { signal in
            guard let signalInfo = signal.userInfo as? [String: Any],
                  let signalType = signalInfo["action"] as? String? else { return }
            if signalType == EmotionSignal.show.rawValue {
                manageControlPanel(.show)
            } else {
                manageControlPanel(.hide)
            }
        }
    }
    
    private func manageControlPanel(_ signal: EmotionSignal) {
        withAnimation(.linear(duration: 0.4)) {
            switch signal {
            case .show:
                isControlPanelVisible = true
            case .hide:
                isControlPanelVisible = false
            default:
                break
            }
        }
    }
}

struct EmotionControlPanel: View {
    let onBack: () -> Void
    let onReload: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
            HStack {
                MoodActionButton(symbol: "arrow.left", action: onBack)
                Spacer()
                MoodActionButton(symbol: "arrow.clockwise", action: onReload)
            }
            .padding(6)
        }
        .frame(height: 60)
    }
}

struct MoodActionButton: View {
    let symbol: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
        }
    }
}

struct EmotionDisplayView: UIViewRepresentable {
    let moodPath: URL
    @StateObject private var moodManager = MoodManager()
    
    func makeUIView(context: Context) -> WKWebView {
        moodManager.prepareMoodSphere()
        moodManager.primarySphere.uiDelegate = context.coordinator
        moodManager.primarySphere.navigationDelegate = context.coordinator
        moodManager.restoreMoodData()
        return moodManager.primarySphere
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: moodPath))
    }
    
    func makeCoordinator() -> MoodSphereCoordinator {
        MoodSphereCoordinator(moodManager: moodManager)
    }
}

class MoodManager: ObservableObject {
    @Published var primarySphere: WKWebView!
    @Published var secondarySpheres: [WKWebView] = []
    
    func prepareMoodSphere() {
        primarySphere = MoodUtils.createMoodSphere()
        primarySphere.allowsBackForwardNavigationGestures = true
    }
    
    func restoreMoodData() {
        guard let savedMoodData = UserDefaults.standard.dictionary(forKey: "cccoookkkey") as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else { return }
        let moodStorage = primarySphere.configuration.websiteDataStore.httpCookieStore
        
        savedMoodData.values.flatMap { $0.values }.forEach { moodProperties in
            if let moodCookie = HTTPCookie(properties: moodProperties as! [HTTPCookiePropertyKey: Any]) {
                moodStorage.setCookie(moodCookie)
            }
        }
    }
    
    func refreshMoodContent() {
        primarySphere.reload()
    }
    
    func clearSecondarySpheresIfNeeded() {
        if MoodUtils.shouldClearSecondarySpheres(primarySphere, secondarySpheres, moodPath: primarySphere.url) {
            secondarySpheres.removeAll()
        }
    }
}

class MoodSphereCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    private let moodManager: MoodManager
    private let emotionSignal = EmotionSignalManager()
    
    init(moodManager: MoodManager) {
        self.moodManager = moodManager
        super.init()
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else {
            emotionSignal.sendSignal(.hide)
            return nil
        }
        
        let newSphere = createSecondaryMoodSphere(with: configuration)
        configureSecondaryMoodSphere(newSphere)
        attachSecondarySphereToPrimary(newSphere)
        
        emotionSignal.sendSignal(.show)
        moodManager.secondarySpheres.append(newSphere)
        loadMoodPathIfValid(newSphere, moodPath: navigationAction.request)
        return newSphere
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NotificationCenter.default.addObserver(self, selector: #selector(processSignal), name: .allMoodSignals, object: nil)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        storeMoodData(from: webView)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let moodPath = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        let externalMoodLinks = ["tg://", "dnsajkd://", "viber://", "whatsapp://", "dsad://"]
        if externalMoodLinks.contains(where: moodPath.absoluteString.hasPrefix) {
            UIApplication.shared.open(moodPath, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    @objc private func processSignal(_ notification: Notification) {
        guard let info = notification.userInfo as? [String: Any], let signal = info["action"] as? String else { return }
        switch signal {
        case "back": moodManager.clearSecondarySpheresIfNeeded()
        case "reload": moodManager.refreshMoodContent()
        default: break
        }
    }
    
    private func createSecondaryMoodSphere(with configuration: WKWebViewConfiguration) -> WKWebView {
        let secondarySphere = WKWebView(frame: .zero, configuration: configuration)
        secondarySphere.scrollView.isScrollEnabled = true
        secondarySphere.navigationDelegate = self
        secondarySphere.uiDelegate = self
        return secondarySphere
    }
    
    private func configureSecondaryMoodSphere(_ sphere: WKWebView) {
        sphere.translatesAutoresizingMaskIntoConstraints = false
        sphere.allowsBackForwardNavigationGestures = true
        moodManager.primarySphere.addSubview(sphere)
    }
    
    private func attachSecondarySphereToPrimary(_ sphere: WKWebView) {
        NSLayoutConstraint.activate([
            sphere.topAnchor.constraint(equalTo: moodManager.primarySphere.topAnchor),
            sphere.bottomAnchor.constraint(equalTo: moodManager.primarySphere.bottomAnchor),
            sphere.leadingAnchor.constraint(equalTo: moodManager.primarySphere.leadingAnchor),
            sphere.trailingAnchor.constraint(equalTo: moodManager.primarySphere.trailingAnchor)
        ])
    }
    
    private func loadMoodPathIfValid(_ sphere: WKWebView, moodPath: URLRequest) {
        let pathString = moodPath.url?.absoluteString ?? ""
        if pathString == "about:blank" || pathString.isEmpty {
            // Пропускаем пустые пути
        } else {
            sphere.load(moodPath)
        }
    }
    
    private func storeMoodData(from sphere: WKWebView) {
        sphere.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            var moodStorage: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            for cookie in cookies {
                var domainMoods = moodStorage[cookie.domain] ?? [:]
                domainMoods[cookie.name] = cookie.properties as? [HTTPCookiePropertyKey: Any]
                moodStorage[cookie.domain] = domainMoods
            }
            UserDefaults.standard.set(moodStorage, forKey: "cccoookkkey")
        }
    }
}

class EmotionSignalManager {
    let signalPublisher = NotificationCenter.default.publisher(for: .allMoodSignals)
    
    func sendSignal(_ signal: EmotionSignal) {
        NotificationCenter.default.post(name: .allMoodSignals, object: nil, userInfo: ["action": signal.rawValue])
    }
}

enum EmotionSignal: String {
    case show
    case hide
    case back
    case reload
}

extension Notification.Name {
    static let allMoodSignals = Notification.Name("mood_signal")
}

struct MoodUtils {
    static func createMoodSphere() -> WKWebView {
        func prepareSpherePreferences() -> WKWebpagePreferences {
            let spherePrefs = WKWebpagePreferences()
            spherePrefs.allowsContentJavaScript = true
            return spherePrefs
        }
        
        func setupMoodSettings() -> WKPreferences {
            let moodSettings = WKPreferences()
            moodSettings.javaScriptCanOpenWindowsAutomatically = true
            moodSettings.javaScriptEnabled = true
            return moodSettings
        }
        
        func configureMoodSphere() -> WKWebViewConfiguration {
            let sphereConfig = WKWebViewConfiguration()
            sphereConfig.allowsInlineMediaPlayback = true
            sphereConfig.defaultWebpagePreferences = prepareSpherePreferences()
            sphereConfig.requiresUserActionForMediaPlayback = false
            sphereConfig.preferences = setupMoodSettings()
            return sphereConfig
        }
        
        return WKWebView(frame: .zero, configuration: configureMoodSphere())
    }
    
    static func shouldClearSecondarySpheres(_ sphere: WKWebView, _ secondarySpheres: [WKWebView], moodPath: URL?) -> Bool {
        if !secondarySpheres.isEmpty {
            secondarySpheres.forEach { $0.removeFromSuperview() }
            sphere.load(URLRequest(url: moodPath!))
            NotificationCenter.default.post(name: .allMoodSignals, object: nil, userInfo: ["action": EmotionSignal.hide.rawValue])
            return true
        } else if sphere.canGoBack {
            sphere.goBack()
            return false
        }
        return false
    }
}
