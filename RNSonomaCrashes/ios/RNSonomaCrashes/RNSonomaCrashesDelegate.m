#import "RNSonomaCrashesDelegate.h"

#import "RCTEventDispatcher.h"
#import "RNSonomaCrashesUtils.h"

@import SonomaCrashes.SNMErrorAttachment;

static NSString *ON_BEFORE_SENDING_EVENT = @"SonamaErrorReportOnBeforeSending";
static NSString *ON_SENDING_FAILED_EVENT = @"SonamaErrorReportOnSendingFailed";
static NSString *ON_SENDING_SUCCEEDED_EVENT = @"SonamaErrorReportOnSendingSucceeded";


@implementation RNSonomaCrashesDelegateBase

- (instancetype) init
{
    self.reports = [[NSMutableArray alloc] init];
    return self;
}

- (BOOL) crashes:(SNMCrashes *)crashes shouldProcessErrorReport:(SNMErrorReport *)errorReport
{
    // By default handle all reports and expose them all to JS.
    [self storeReportForJS: errorReport];
    return YES;
}

- (SNMUserConfirmationHandler)shouldAwaitUserConfirmationHandler
{
    // Do not send anything until instructed to by JS
    return ^(NSArray<SNMErrorReport *> *errorReports){
        return YES;
    };
}

- (void)storeReportForJS:(SNMErrorReport *) report
{
    [self.reports addObject:report];
}

- (void) crashes:(SNMCrashes *)crashes willSendErrorReport:(SNMErrorReport *)errorReport
{
    [self.bridge.eventDispatcher sendAppEventWithName:ON_BEFORE_SENDING_EVENT body:convertReportToJS(errorReport)];
}

- (void) crashes:(SNMCrashes *)crashes didSucceedSendingErrorReport:(SNMErrorReport *)errorReport
{
    [self.bridge.eventDispatcher sendAppEventWithName:ON_SENDING_SUCCEEDED_EVENT body:convertReportToJS(errorReport)];
}

- (void) crashes:(SNMCrashes *)crashes didFailSendingErrorReport:(SNMErrorReport *)errorReport withError:(NSError *)sendError
{
    [self.bridge.eventDispatcher sendAppEventWithName:ON_SENDING_FAILED_EVENT body:convertReportToJS(errorReport)];
}

- (void) provideAttachments: (NSDictionary*) attachments
{
    self.attachments = attachments;
}

- (SNMErrorAttachment *)attachmentWithCrashes:(SNMCrashes *)crashes forErrorReport:(SNMErrorReport *)errorReport
{
    NSObject* attachment = [self.attachments objectForKey:[errorReport incidentIdentifier]];
    if (attachment && [attachment isKindOfClass:[NSString class]]) {
        NSString * stringAttachment = (NSString *)attachment;
        return [SNMErrorAttachment attachmentWithText:stringAttachment];
    }

    return nil;
}

- (NSArray<SNMErrorReport *>*) getAndClearReports
{
    NSArray<SNMErrorReport *>* result = self.reports;
    self.reports = [[NSMutableArray alloc] init];
    return result;
}

@end

@implementation RNSonomaCrashesDelegateAlwaysSend
- (BOOL) crashes:(SNMCrashes *)crashes shouldProcessErrorReport:(SNMErrorReport *)errorReport
{
    // Do not pass the report to JS, but do process them
    return YES;
}

- (SNMUserConfirmationHandler)shouldAwaitUserConfirmationHandler
{
    // Do not wait for user confirmation, always send.
    return ^(NSArray<SNMErrorReport *> *errorReports){
        return NO;
    };
}

@end
