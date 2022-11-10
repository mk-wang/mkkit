//
//  GHConsole.m
//  GHConsole
//
//  Created by liaoWorking on 22/11/2017.
//  Copyright © 2017 廖光辉. All rights reserved.
//  https://github.com/Liaoworking/GHConsole for lastest version
//

#import "GHConsole.h"
#import <pthread/pthread.h>
#import <sys/uio.h>
#import <unistd.h>

#define k_WIDTH [UIScreen mainScreen].bounds.size.width
#define BTN_X_PAD 20.0f
#define BTN_WIDTH 60.0f
#define BTN_HEIGHT 44.0f

NS_INLINE CGRect _fixRect(CGRect origin)
{
    CGRect rect = origin;
    CGSize screenSize = UIScreen.mainScreen.bounds.size;

    if (rect.origin.x < 0) {
        rect.origin.x = 0;
    }

    CGFloat maxX = screenSize.width - rect.size.width;
    if (rect.origin.x > maxX) {
        rect.origin.x = maxX;
    }

    if (rect.origin.y < 0) {
        rect.origin.y = 0;
    }
    CGFloat maxY = screenSize.height - rect.size.height;
    if (rect.origin.y > maxY) {
        rect.origin.y = maxY;
    }

    return rect;
}

typedef void (^clearTextBlock)(void);
typedef void (^readTextBlock)(void);

@interface GHConsoleRootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
@public
    UITableView *_tableView;
    UIButton *_clearBtn;
    UIButton *_saveBtn;
    UIButton *_readLogBtn;
    UIButton *_minimize;
    UIImageView *_imgV;
}
@property (nonatomic) BOOL scrollEnable;
@property (nonatomic, copy) clearTextBlock clearLogText;
@property (nonatomic, copy) readTextBlock readLog;
@property (nonatomic, strong) void (^minimizeActionBlock)(void);
@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation GHConsoleRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configLogList];
    [self configMinimizeBtn];
    [self configClearBtn];
    //    [self configSaveBtn];
    //    [self configReadBtn];
    [self createImgV];
}

- (void)configLogList
{
    self.view.clipsToBounds = YES;
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorColor = [UIColor whiteColor];
    _tableView.estimatedRowHeight = 44;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    [self.view addSubview:_tableView];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(h)-[_tableView]-0-|" options:0 metrics:@{@"h" : @(BTN_WIDTH)} views:NSDictionaryOfVariableBindings(_tableView)]];
    [_tableView reloadData];
}

- (void)configMinimizeBtn
{
    _minimize = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, BTN_WIDTH, BTN_HEIGHT)];
    [_minimize addTarget:self action:@selector(minimizeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_minimize setTitle:@"X" forState:UIControlStateNormal];
    [_minimize setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    _minimize.layer.borderWidth = 1;
    _minimize.layer.borderColor = UIColor.grayColor.CGColor;
    [self.view addSubview:_minimize];
}

- (void)configClearBtn
{
    CGRect rect = _minimize.frame;
    rect.origin.x = CGRectGetMaxX(rect) + BTN_X_PAD;
    _clearBtn = [[UIButton alloc] initWithFrame:rect];
    [_clearBtn addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
    [_clearBtn setTitle:@"C" forState:UIControlStateNormal];
    [_clearBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    _clearBtn.layer.borderWidth = 1;
    _clearBtn.layer.borderColor = UIColor.grayColor.CGColor;
    [self.view addSubview:_clearBtn];
}

- (void)createImgV
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GHConsole.bundle" ofType:nil];
    path = [path stringByAppendingPathComponent:@"icon.png"];
    _imgV = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
    _imgV.userInteractionEnabled = YES;
    _imgV.frame = self.view.bounds;
    _imgV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imgV.layer.shadowOpacity = 0.5;
    _imgV.layer.shadowOffset = CGSizeZero;
    [self.view addSubview:_imgV];
}

- (void)minimizeAction:(UIButton *)sender
{
    if (_minimizeActionBlock) {
        _minimizeActionBlock();
    }
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    [_tableView reloadData];
}

- (void)clearText
{
    if (self.clearLogText) {
        self.clearLogText();
    }
}

- (void)setScrollEnable:(BOOL)scrollEnable
{
    _tableView.scrollEnabled = scrollEnable;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Cell];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITextView *textView = [[UITextView alloc] init];
        textView.scrollEnabled = NO;
        textView.textContainer.lineFragmentPadding = 0;
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = [UIColor whiteColor];
        textView.font = [UIFont systemFontOfSize:13];
        textView.tag = 100;
        textView.editable = NO;
        textView.userInteractionEnabled = YES;
        [cell.contentView addSubview:textView];
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[textView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[textView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
    }
    NSString *str = self.dataSource[indexPath.row];
    UITextView *textView = [cell.contentView viewWithTag:100];
    textView.text = str;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = self.dataSource[indexPath.row];
    CGRect rect = [str boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil];
    return ceil(rect.size.height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end

#pragma mark - GHConsoleWindow
@interface GHConsoleWindow : UIWindow

+ (instancetype)consoleWindow;

/**
  to make the GHConsole full-screen.
 */
- (void)maxmize;

/**
 to make the GHConsole at the right side in your app
 */
- (void)minimize;

/**
 the point of origin X-axis and Y-axis
 */
@property (nonatomic, assign) CGPoint axisXY;

@property (nonatomic, strong) GHConsoleRootViewController *consoleRootViewController;
@end

@implementation GHConsoleWindow
+ (instancetype)consoleWindow
{
    GHConsoleWindow *window = [[self alloc] init];
    window.windowLevel = UIWindowLevelNormal;
    window.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 120, 50, 50);
    window.clipsToBounds = YES;
    return window;
}

- (GHConsoleRootViewController *)consoleRootViewController
{
    return (GHConsoleRootViewController *)self.rootViewController;
}

- (void)maxmize
{
    CGRect rect = self.frame;
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    rect.size.width = MIN(screenSize.width * 0.8, 320);
    rect.size.height = 160;
    rect = _fixRect(rect);

    self.consoleRootViewController.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
    self.frame = rect;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.consoleRootViewController.scrollEnable = YES;
    self.backgroundColor = [UIColor clearColor];
    self.consoleRootViewController->_imgV.alpha = 0;
    self.consoleRootViewController->_minimize.alpha = 1.0;
    self.consoleRootViewController->_readLogBtn.alpha = 1.0;
    self.consoleRootViewController->_clearBtn.alpha = 1.0;
    self.consoleRootViewController->_saveBtn.alpha = 1.0;
    self.consoleRootViewController->_tableView.alpha = 1.0;
}

- (void)minimize
{
    self.consoleRootViewController.view.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(_axisXY.x, _axisXY.y, 50, 50);
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.consoleRootViewController.scrollEnable = NO;
    self.consoleRootViewController->_imgV.alpha = 1.0;
    self.consoleRootViewController->_minimize.alpha = 0;
    self.consoleRootViewController->_readLogBtn.alpha = 0;
    self.consoleRootViewController->_clearBtn.alpha = 0;
    self.consoleRootViewController->_saveBtn.alpha = 0;
    self.consoleRootViewController->_tableView.alpha = 0;
    self.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].delegate.window.rootViewController setNeedsStatusBarAppearanceUpdate];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.rootViewController.view.frame = self.bounds;
}
@end

#pragma mark - GHConsole
@interface GHConsole () {
    NSDate *_timestamp;
    NSString *_timeString;
}

@property (nonatomic, strong) NSString *string;
@property (nonatomic, assign) BOOL isShowConsole;
@property (nonatomic, strong) NSMutableArray *logStingArray;
@property (nonatomic, copy) NSString *funcString;

@property (nonatomic, assign) NSInteger currentLogCount;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) UIPanGestureRecognizer *panOutGesture;
@property (nonatomic, strong) GHConsoleWindow *consoleWindow;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, copy) NSString *msgString;
@property (nonatomic, strong) NSDate *now;
@property (nonatomic, strong) NSLock *lock;
@end
@implementation GHConsole

+ (instancetype)sharedConsole
{
    static GHConsole *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [GHConsole new];
        _instance.isShowConsole = NO;
    });

    return _instance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (GHConsoleWindow *)consoleWindow
{
    if (!_consoleWindow) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        _consoleWindow = [GHConsoleWindow consoleWindow];
        _consoleWindow.rootViewController = [GHConsoleRootViewController new];
        _consoleWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
        _consoleWindow.axisXY = _consoleWindow.frame.origin;
        __weak __typeof__(self) weakSelf = self;
        _consoleWindow.consoleRootViewController.clearLogText = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf clearAllText];
        };
        _consoleWindow.consoleRootViewController.readLog = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf readSavedText];
        };
        UITapGestureRecognizer *tappGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];

        [_consoleWindow.rootViewController.view addGestureRecognizer:self.panOutGesture];
        [_consoleWindow.consoleRootViewController->_imgV addGestureRecognizer:tappGest];
        _consoleWindow.consoleRootViewController.minimizeActionBlock = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf minimizeAnimation];
        };
        _consoleWindow.backgroundColor = [UIColor clearColor];
        self.consoleWindow.consoleRootViewController->_imgV.alpha = 1.0;
        self.consoleWindow.consoleRootViewController->_saveBtn.alpha = 0;
        self.consoleWindow.consoleRootViewController->_readLogBtn.alpha = 0;
        self.consoleWindow.consoleRootViewController->_clearBtn.alpha = 0;
        self.consoleWindow.consoleRootViewController->_minimize.alpha = 0;
        self.consoleWindow.consoleRootViewController->_tableView.alpha = 0;
    }
    return _consoleWindow;
}

/**
 start printing
 */
- (void)startPrintLog
{
    _isFullScreen = NO;
    _isShowConsole = YES;
    self.consoleWindow.hidden = NO;
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    _lock = [NSLock new];

    //如果想在release情况下也能显示控制台打印请把stopPrinting方法注释掉
    // if you want to see GHConsole at the release mode you will annotating the stopPrinting func below here.
#ifndef DEBUG
//    [self stopPrinting];
#endif
}
/**
 stop printing
 */
- (void)stopPrinting
{
    self.consoleWindow.hidden = YES;
    _isShowConsole = NO;
}

- (void)function:(const char *)function
            line:(NSUInteger)line
          format:(NSString *)format, ... NS_FORMAT_FUNCTION(3, 4)
{
    va_list args;

    if (format) {
        va_start(args, format);

        _msgString = [[NSString alloc] initWithFormat:format arguments:args];
        // showing log in UI
        [_lock lock];
        [self printMSG:_msgString andFunc:function andLine:line];
        [_lock unlock];
    }
}

- (void)printMSG:(NSString *)msg andFunc:(const char *)function andLine:(NSInteger)Line
{
    // convert C function name to OC
    _funcString = [NSString stringWithUTF8String:function];

    _now = [NSDate new];
    msg = [NSString stringWithFormat:@"%@ %@ line-%ld\n%@\n\n", [_formatter stringFromDate:_now], _funcString, (long)Line, msg];

    [self _print:msg];
}

- (void)print:(NSString *)msg
{
    _now = [NSDate new];
    msg = [NSString stringWithFormat:@"%@ %@\n", [_formatter stringFromDate:_now], msg];
    [self _print:msg];
}

- (void)_print:(NSString *)msg
{
    //    if ([msg canBeConvertedToEncoding:NSUTF8StringEncoding]) {
    //        const char *resultCString = [msg cStringUsingEncoding:NSUTF8StringEncoding];
    //        printf("%s", resultCString);
    //    }

    if (msg.length > 0 && [msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [self.logStingArray addObject:msg];
    }

    __weak __typeof(self) weakSelf = self;
    if (_isShowConsole && _isFullScreen) {
        //如果显示的话手机上的控制台开始显示。
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.consoleWindow.consoleRootViewController.dataSource = weakSelf.logStingArray;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(100 * NSEC_PER_MSEC)),
                           dispatch_get_main_queue(),
                           ^{
                               [weakSelf scrollToBottom];
                           });
        });
    }
}

- (void)clearAllText
{
    [self.logStingArray removeAllObjects];
    self.consoleWindow.consoleRootViewController.dataSource = self.logStingArray;
}

- (void)readSavedText
{
    NSData *savedString = [[NSUserDefaults standardUserDefaults] objectForKey:@"textSaveKey"];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:savedString options:NSJSONReadingAllowFragments error:nil];
    self.logStingArray = [NSMutableArray arrayWithArray:array];
    [self.logStingArray addObject:@"\n-----------------RECORD-----------------\n\n"];
    self.consoleWindow.consoleRootViewController.dataSource = self.logStingArray;
}

- (NSMutableArray *)logStingArray
{
    if (!_logStingArray) {
        _logStingArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _logStingArray;
}

- (void)handleReceiveMemoryWarningNotification
{
    [self.logStingArray removeAllObjects];
    [self.logStingArray addObject:@"收到了系统内存警告!所有日志被清空!"];
    self.consoleWindow.consoleRootViewController.dataSource = self.logStingArray;
}

#pragma mark - gesture function
- (void)panGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:gesture.view];
        CGRect rect = CGRectOffset(self.consoleWindow.frame, translation.x, translation.y);
        self.consoleWindow.frame = _fixRect(rect);
        [gesture setTranslation:CGPointZero inView:gesture.view];
    }
}
/**
tap
 */
- (void)tapImageView:(UITapGestureRecognizer *)tapGesture
{
    [self maximumAnimation];
}

//全屏
- (void)maximumAnimation
{
    if (!_isFullScreen) {
        // becoma full screen
        self.consoleWindow.consoleRootViewController.dataSource = self.logStingArray;
        [UIView animateWithDuration:0.25
            animations:^{
                [self.consoleWindow maxmize];
            }
            completion:^(BOOL finished) {
                self->_isFullScreen = YES;
                if (!finished) {
                    [self.consoleWindow maxmize];
                }
                [self scrollToBottom];
            }];
    }
}

- (void)minimizeAnimation
{
    //退出全屏
    [UIView animateWithDuration:0.25
        animations:^{
            [self.consoleWindow minimize];
        }
        completion:^(BOOL finished) {
            self->_isFullScreen = NO;
            if (!finished) {
                [self.consoleWindow minimize];
            }
        }];
}

- (void)scrollToBottom
{
    if (self.logStingArray.count == 0) {
        return;
    }

    UITableView *tableView = self.consoleWindow.consoleRootViewController->_tableView;
    CGPoint bottomOffset = CGPointMake(0, tableView.contentSize.height - tableView.bounds.size.height + tableView.contentInset.bottom);
    [tableView setContentOffset:bottomOffset animated:YES];
}

- (UIPanGestureRecognizer *)panOutGesture
{
    if (!_panOutGesture) {
        _panOutGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    }
    return _panOutGesture;
}

@end
