#import "ManualViewControllerIOS.h"

@implementation ManualViewControllerIOS

// @synthesize webView;

- (void) viewDidAppear: (BOOL) animated
{
    self.title = @"User Guide";
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSURL *url = [mainBundle URLForResource:
                   @"manual/index" withExtension: @"html"];
    
    // NSLog( @"url=%@", url );
    
    [webView loadRequest: [NSURLRequest requestWithURL: url ] ];

    [super viewDidAppear: animated];
    
    return;
}
@end