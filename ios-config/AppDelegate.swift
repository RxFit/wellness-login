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

        // Check a representative sample across all categories
        let typesToCheck: [HKSampleType] = [
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKQuantityType.quantityType(forIdentifier: .bodyMass),
            HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed),
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis),
        ].compactMap { $0 }

        guard !typesToCheck.isEmpty else {
            task.setTaskCompleted(success: true)
            return
        }

        let group = DispatchGroup()
        var hasNewData = false
        let lock = NSLock()

        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: oneHourAgo, end: Date(), options: .strictStartDate)

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
                    lock.lock()
                    hasNewData = true
                    lock.unlock()
                }
                group.leave()
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            if hasNewData {
                self.performBackgroundSync { task.setTaskCompleted(success: true) }
            } else {
                task.setTaskCompleted(success: true)
            }
        }
    }

    private func performBackgroundSync(completion: @escaping () -> Void) {
        let syncManager = HealthKitSyncManager()
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()

        syncManager.queryAllSamples(
            healthStore: healthStore,
            startDate: oneHourAgo,
            endDate: Date()
        ) { samples, deviceInfo in
            guard !samples.isEmpty else {
                completion()
                return
            }

            guard let url = URL(string: "https://app.rxfit.ai/api/healthkit/sync") else {
                completion()
                return
            }

            let body: [String: Any] = [
                "samples": samples,
                "deviceInfo": deviceInfo,
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
                completion()
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = 25

            if let cookieURL = URL(string: "https://app.rxfit.ai"),
               let cookies = HTTPCookieStorage.shared.cookies(for: cookieURL) {
                let headers = HTTPCookie.requestHeaderFields(with: cookies)
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }

            URLSession.shared.dataTask(with: request) { _, _, _ in
                completion()
            }.resume()
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
