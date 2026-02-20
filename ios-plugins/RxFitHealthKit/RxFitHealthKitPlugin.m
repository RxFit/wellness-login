#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(RxFitHealthKitPlugin, "RxFitHealthKit",
    CAP_PLUGIN_METHOD(requestAuthorization, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(queryAllSamples, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(enableBackgroundDelivery, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(isAvailable, CAPPluginReturnPromise);
)
