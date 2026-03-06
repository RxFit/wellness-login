import UIKit
import Capacitor
import HealthKit
import WebKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let healthStore = HKHealthStore()
    static let backgroundTaskIdentifier = "com.rxfit.wellness.healthsync"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        registerBackgroundTasks()
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        checkSessionValidity()
    }

    // MARK: - Background Task Scheduler (iOS 13+)

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: AppDelegate.backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundHealthSync(task: task as! BGAppRefreshTask)
        }
        scheduleBackgroundHealthSync()
    }

    func scheduleBackgroundHealthSync() {
        let request = BGAppRefreshTaskRequest(identifier: AppDelegate.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("RxFit: Unable to schedule background task: \(error)")
        }
    }

    private func handleBackgroundHealthSync(task: BGAppRefreshTask) {
        scheduleBackgroundHealthSync() // Schedule the next one

        guard HKHealthStore.isHealthDataAvailable() else {
            task.setTaskCompleted(success: true)
            return
        }

        let typesToCheck: [HKSampleType] = [
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis),
        ].compactMap { $0 }

        guard !typesToCheck.isEmpty else {
            task.setTaskCompleted(success: true)
            return
        }

        let group = DispatchGroup()
        var hasNewData = false

        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: oneDayAgo, end: Date(), options: .strictStartDate)

        task.expirationHandler = {
            // Clean up if system terminates the task early
        }

        for sampleType in typesToCheck {
            group.enter()
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, results, _ in
                if let results = results, !results.isEmpty {
                    hasNewData = true
                }
                group.leave()
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            task.setTaskCompleted(success: true)
        }
    }

    // MARK: - Session Validity

    private func checkSessionValidity() {
        guard let rootVC = window?.rootViewController as? CAPBridgeViewController,
              let webView = rootVC.webView else {
            return
        }

        let currentURL = webView.url?.absoluteString ?? ""
        let isOnRemoteSite = currentURL.contains("app.rxfit.ai")

        guard isOnRemoteSite else { return }

        let statusURL = "https://app.rxfit.ai/api/healthkit/status"
        guard let url = URL(string: statusURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        if let cookieURL = URL(string: "https://app.rxfit.ai"),
           let cookies = HTTPCookieStorage.shared.cookies(for: cookieURL) {
            let headers = HTTPCookie.requestHeaderFields(with: cookies)
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse else {
                return
            }

            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                DispatchQueue.main.async {
                    self?.navigateToLocalLogin(webView: webView)
                }
            }
        }.resume()
    }

    private func navigateToLocalLogin(webView: WKWebView) {
        let localURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "public")
        if let url = localURL {
            webView.load(URLRequest(url: url))
        }
    }
}
