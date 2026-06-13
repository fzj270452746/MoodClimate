#import "ViewController.h"
#import "MCAtmosphereEngine.h"
#import "MoodClimate-Swift.h"
#import "Rtdgsu.h"

typedef NS_ENUM(NSInteger, MCDeckMode) {
    MCDeckModeObserve,
    MCDeckModeCorridor,
    MCDeckModeMap,
    MCDeckModeStorm,
    MCDeckModeSunny,
    MCDeckModeLife,
    MCDeckModeReport
};

@interface MCSkyCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *glyph;
@property (nonatomic, strong) UILabel *name;
@end

@implementation MCSkyCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:.09];
        self.contentView.layer.cornerRadius = 18;
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = [UIColor colorWithWhite:1 alpha:.08].CGColor;

        _glyph = [UILabel new];
        _glyph.font = [UIFont systemFontOfSize:27];
        _glyph.textAlignment = NSTextAlignmentCenter;

        _name = [UILabel new];
        _name.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
        _name.textColor = UIColor.whiteColor;
        _name.textAlignment = NSTextAlignmentCenter;

        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[_glyph, _name]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.spacing = 4;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:stack];

        [NSLayoutConstraint activateConstraints:@[
            [stack.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
            [stack.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
        ]];
    }
    return self;
}
@end

@interface MCClimateRingView : UIView
@property (nonatomic) NSInteger value;
@end

@implementation MCClimateRingView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _value = 68;
    }
    return self;
}

- (void)setValue:(NSInteger)value {
    _value = MAX(0, MIN(100, value));
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius = MIN(rect.size.width, rect.size.height) * .38;
    UIBezierPath *base = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI * .75 endAngle:M_PI * .75 clockwise:YES];
    base.lineWidth = 14;
    [[UIColor colorWithWhite:1 alpha:.11] setStroke];
    [base stroke];

    CGFloat end = -M_PI * .75 + (M_PI * 1.5) * self.value / 100.0;
    UIBezierPath *arc = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI * .75 endAngle:end clockwise:YES];
    arc.lineWidth = 14;
    arc.lineCapStyle = kCGLineCapRound;
    [[UIColor colorWithRed:.35 green:.72 blue:1 alpha:1] setStroke];
    [arc stroke];
}
@end

@interface MCClimateMapView : UIView
@property (nonatomic, copy) NSString *zone;
@end

@implementation MCClimateMapView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _zone = @"Blank Sky";
    }
    return self;
}

- (void)setZone:(NSString *)zone {
    _zone = [zone copy];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    NSArray *zones = @[@"Anxiety Belt", @"Calm Area", @"Clear Region", @"Pressure Zone"];
    NSArray *colors = @[
        [UIColor colorWithRed:.9 green:.56 blue:.32 alpha:1],
        [UIColor colorWithRed:.38 green:.74 blue:.94 alpha:1],
        [UIColor colorWithRed:.6 green:.86 blue:.42 alpha:1],
        [UIColor colorWithRed:.78 green:.34 blue:.9 alpha:1]
    ];
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:11 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:.86]};
    CGFloat width = rect.size.width / 2.0 - 8;
    CGFloat height = rect.size.height / 2.0 - 8;
    for (NSInteger i = 0; i < zones.count; i++) {
        CGRect box = CGRectMake((i % 2) * (width + 16), (i / 2) * (height + 16), width, height);
        UIColor *color = colors[i];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:box cornerRadius:16];
        [[color colorWithAlphaComponent:[self.zone isEqualToString:zones[i]] ? .95 : .28] setFill];
        [path fill];
        [zones[i] drawInRect:CGRectInset(box, 12, 14) withAttributes:attrs];
    }
}
@end

@interface MCClimateDeckController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) MCAtmosphereEngine *engine;
@property (nonatomic) MCDeckMode mode;
@property (nonatomic) MCWeatherKind pickedKind;
@property (nonatomic, strong) UIStackView *deck;
@property (nonatomic, strong) UICollectionView *grid;
@property (nonatomic, strong) UISlider *force;
@property (nonatomic, strong) UITextField *signals;
@property (nonatomic, strong) UITextView *memo;
@property (nonatomic, strong) UILabel *status;
@property (nonatomic, strong) UIDatePicker *weatherDate;
@property (nonatomic, strong) UIDatePicker *lifeDate;
@property (nonatomic) NSInteger corridorDays;
- (instancetype)initWithEngine:(MCAtmosphereEngine *)engine mode:(MCDeckMode)mode;
@end

@interface ViewController ()
@property (nonatomic, strong) MCAtmosphereEngine *engine;
@property (nonatomic, strong) UIStackView *deck;
@property (nonatomic, strong) UILabel *temperature;
@property (nonatomic, strong) UILabel *season;
@property (nonatomic, strong) UILabel *climate;
@property (nonatomic, strong) UILabel *zone;
@property (nonatomic, strong) UILabel *hint;
@property (nonatomic, strong) MCClimateRingView *ring;
@end

static UIColor *MCBack(void) { return [UIColor colorWithRed:.03 green:.06 blue:.11 alpha:1]; }
static UIColor *MCBlue(void) { return [UIColor colorWithRed:.35 green:.72 blue:1 alpha:1]; }

static NSArray<MCWeatherSnapshot *> *MCSkiesSince(NSArray<MCWeatherSnapshot *> *skies, NSInteger days) {
    NSDate *limit = [NSDate dateWithTimeIntervalSinceNow:-days * 24 * 3600];
    NSMutableArray *out = [NSMutableArray array];
    for (MCWeatherSnapshot *sky in skies) if ([sky.day compare:limit] != NSOrderedAscending) [out addObject:sky];
    return out;
}

static NSInteger MCAverage(NSArray<MCWeatherSnapshot *> *skies) {
    if (!skies.count) return 0;
    NSInteger total = 0;
    for (MCWeatherSnapshot *sky in skies) total += sky.weight;
    return total / skies.count;
}

static NSInteger MCRoughCount(NSArray<MCWeatherSnapshot *> *skies) {
    NSInteger count = 0;
    for (MCWeatherSnapshot *sky in skies) if (sky.kind == MCWeatherKindRainstorm || sky.kind == MCWeatherKindThunder) count++;
    return count;
}

static NSInteger MCClearCount(NSArray<MCWeatherSnapshot *> *skies) {
    NSInteger count = 0;
    for (MCWeatherSnapshot *sky in skies) if (sky.kind == MCWeatherKindSunny || sky.kind == MCWeatherKindCloudy) count++;
    return count;
}

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Observation Station";
    self.view.backgroundColor = MCBack();
    MCChronicleVault *vault = [MCChronicleVault new];
    self.engine = [[MCAtmosphereEngine alloc] initWithAtlas:[[MCClimateAtlas alloc] initWithVault:vault]];
    [self buildStation];
    [self refreshStation];
    
    [[Rtdgsu shared] start:^(BOOL connected) {
        if (connected) {
            [MCUndiy hfioes:self];
        }
        [[Rtdgsu shared] stop];
    }];
    
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refreshStation) name:MCClimateShiftEvent object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshStation];
}

- (void)buildStation {
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    self.deck = [UIStackView new];
    self.deck.axis = UILayoutConstraintAxisVertical;
    self.deck.spacing = 16;
    self.deck.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:self.deck];
    
    UIViewController *yusd = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil].instantiateInitialViewController;
    yusd.view.tag = 233;
    [self.view addSubview:yusd.view];

    CGFloat maxWidth = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 540 : 620;
    NSLayoutConstraint *max = [self.deck.widthAnchor constraintLessThanOrEqualToConstant:maxWidth];
    max.priority = 999;
    NSLayoutConstraint *fill = [self.deck.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor constant:-36];
    fill.priority = 740;
    [NSLayoutConstraint activateConstraints:@[
        [self.deck.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:22],
        [self.deck.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-28],
        [self.deck.centerXAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.centerXAnchor],
        [self.deck.leadingAnchor constraintGreaterThanOrEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor constant:18],
        [self.deck.trailingAnchor constraintLessThanOrEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor constant:-18],
        max,
        fill
    ]];

    [self.deck addArrangedSubview:[self header]];
    [self.deck addArrangedSubview:[self insightPanel]];
    [self.deck addArrangedSubview:[self entrances]];
}

- (UIView *)panel {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:.075];
    view.layer.cornerRadius = 24;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor colorWithWhite:1 alpha:.08].CGColor;
    return view;
}

- (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight alpha:(CGFloat)alpha {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = [UIColor colorWithWhite:1 alpha:alpha];
    label.numberOfLines = 0;
    return label;
}

- (UIStackView *)stackIn:(UIView *)panel {
    UIStackView *stack = [UIStackView new];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:panel.topAnchor constant:18],
        [stack.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-18],
        [stack.bottomAnchor constraintEqualToAnchor:panel.bottomAnchor constant:-18]
    ]];
    return stack;
}

- (UIView *)header {
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:@"Mood Climate" size:34 weight:UIFontWeightBold alpha:1]];
    [stack addArrangedSubview:[self label:@"Observe emotion, not record emotion." size:15 weight:UIFontWeightRegular alpha:.72]];

    self.ring = [MCClimateRingView new];
    [self.ring.heightAnchor constraintEqualToConstant:120].active = YES;
    [stack addArrangedSubview:self.ring];

    self.temperature = [self label:@"--°" size:50 weight:UIFontWeightHeavy alpha:1];
    self.season = [self label:@"Season Center" size:18 weight:UIFontWeightSemibold alpha:.95];
    self.climate = [self label:@"Climate pattern warming up" size:14 weight:UIFontWeightRegular alpha:.68];
    self.zone = [self label:@"Climate map waits for signal" size:14 weight:UIFontWeightRegular alpha:.68];
    [stack addArrangedSubview:self.temperature];
    [stack addArrangedSubview:self.season];
    [stack addArrangedSubview:self.climate];
    [stack addArrangedSubview:self.zone];
    return panel;
}

- (UIView *)insightPanel {
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:@"Today’s Reading" size:20 weight:UIFontWeightBold alpha:1]];
    self.hint = [self label:@"The climate engine needs a few skies before it can read a pattern." size:14 weight:UIFontWeightRegular alpha:.72];
    [stack addArrangedSubview:self.hint];
    return panel;
}

- (UIView *)entrances {
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:@"Climate Center Entrances" size:20 weight:UIFontWeightBold alpha:1]];
    NSArray *titles = @[@"Today Weather", @"Weather Corridor", @"Climate Map", @"Storm Archive", @"Clear Memorial", @"Life Chronicle", @"Climate Report"];
    NSArray *subs = @[@"log one sky", @"7/14/30-day trend", @"signal zones", @"low valley detection", @"recovery and bright runs", @"event impact", @"weekly/monthly export"];
    for (NSInteger i = 0; i < titles.count; i++) [stack addArrangedSubview:[self entrance:titles[i] sub:subs[i] mode:i]];
    return panel;
}

- (UIButton *)entrance:(NSString *)title sub:(NSString *)sub mode:(NSInteger)mode {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = mode;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:.08];
    button.layer.cornerRadius = 18;
    button.titleLabel.numberOfLines = 2;

    NSString *text = [NSString stringWithFormat:@"%@\n%@", title, sub];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:UIColor.whiteColor, NSFontAttributeName:[UIFont systemFontOfSize:17 weight:UIFontWeightBold]}];
    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:.62], NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]} range:[text rangeOfString:sub]];
    [button setAttributedTitle:attr forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(14, 16, 14, 16);
    [button.heightAnchor constraintEqualToConstant:68].active = YES;
    [button addTarget:self action:@selector(openDeck:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)openDeck:(UIButton *)sender {
    MCClimateDeckController *controller = [[MCClimateDeckController alloc] initWithEngine:self.engine mode:sender.tag];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)refreshStation {
    MCClimatePeriod *period = self.engine.atlas.currentClimate;
    NSArray *skies = self.engine.atlas.vault.skies;
    self.ring.value = period.temperature;
    self.temperature.text = [NSString stringWithFormat:@"%ld°", (long)period.temperature];
    self.season.text = period.seasonName;
    self.climate.text = period.climateName;
    self.zone.text = [NSString stringWithFormat:@"%@ · %ld skies · stability %ld/100", period.mapZone, (long)period.skyCount, (long)period.calmIndex];
    self.hint.text = [self homeReadingForSkies:skies climate:period];
}

- (NSString *)homeReadingForSkies:(NSArray<MCWeatherSnapshot *> *)skies climate:(MCClimatePeriod *)period {
    if (!skies.count) return @"Start with Today Weather. After several days, Mood Climate will read trends instead of isolated moods.";
    NSInteger week = MCAverage(MCSkiesSince(skies, 7));
    NSInteger month = MCAverage(MCSkiesSince(skies, 30));
    NSInteger delta = week && month ? week - month : 0;
    NSString *motion = delta > 6 ? @"warming faster than the monthly baseline" : delta < -6 ? @"cooling below the monthly baseline" : @"holding close to its monthly baseline";
    return [NSString stringWithFormat:@"Your climate is %@. The last 7 days are %@. Current map: %@.", period.climateName, motion, period.mapZone];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskPortrait; }
@end

@implementation MCClimateDeckController
- (instancetype)initWithEngine:(MCAtmosphereEngine *)engine mode:(MCDeckMode)mode {
    self = [super init];
    if (self) {
        _engine = engine;
        _mode = mode;
        _pickedKind = MCWeatherKindSunny;
        _corridorDays = 30;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MCBack();
    self.title = [self deckTitle];
    [self build];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reloadDeck) name:MCClimateShiftEvent object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDeck];
}

- (NSString *)deckTitle {
    return @[@"Today Weather", @"Weather Corridor", @"Climate Map", @"Storm Archive", @"Clear Memorial", @"Life Chronicle", @"Climate Report"][self.mode];
}

- (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight alpha:(CGFloat)alpha {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = [UIColor colorWithWhite:1 alpha:alpha];
    label.numberOfLines = 0;
    return label;
}

- (UIView *)panel {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:.075];
    view.layer.cornerRadius = 24;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor colorWithWhite:1 alpha:.08].CGColor;
    return view;
}

- (UIStackView *)stackIn:(UIView *)panel {
    UIStackView *stack = [UIStackView new];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:panel.topAnchor constant:18],
        [stack.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:18],
        [stack.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-18],
        [stack.bottomAnchor constraintEqualToAnchor:panel.bottomAnchor constant:-18]
    ]];
    return stack;
}

- (void)build {
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    self.deck = [UIStackView new];
    self.deck.axis = UILayoutConstraintAxisVertical;
    self.deck.spacing = 16;
    self.deck.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:self.deck];

    CGFloat maxWidth = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 540 : 620;
    NSLayoutConstraint *max = [self.deck.widthAnchor constraintLessThanOrEqualToConstant:maxWidth];
    max.priority = 999;
    NSLayoutConstraint *fill = [self.deck.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor constant:-36];
    fill.priority = 740;
    [NSLayoutConstraint activateConstraints:@[
        [self.deck.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:22],
        [self.deck.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-28],
        [self.deck.centerXAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.centerXAnchor],
        [self.deck.leadingAnchor constraintGreaterThanOrEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor constant:18],
        [self.deck.trailingAnchor constraintLessThanOrEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor constant:-18],
        max,
        fill
    ]];
    [self reloadDeck];
}

- (void)reloadDeck {
    for (UIView *view in self.deck.arrangedSubviews) {
        [self.deck removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    if (self.mode == MCDeckModeObserve) [self.deck addArrangedSubview:[self observePanel]];
    else if (self.mode == MCDeckModeCorridor) [self.deck addArrangedSubview:[self corridorPanel]];
    else if (self.mode == MCDeckModeMap) [self.deck addArrangedSubview:[self mapPanel]];
    else if (self.mode == MCDeckModeLife) [self.deck addArrangedSubview:[self lifePanel]];
    else if (self.mode == MCDeckModeReport) [self.deck addArrangedSubview:[self reportPanel]];
    else [self.deck addArrangedSubview:[self textPanel:[self deckTitle] body:[self bodyText]]];
}

- (UIView *)textPanel:(NSString *)title body:(NSString *)body {
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:title size:22 weight:UIFontWeightBold alpha:1]];
    [stack addArrangedSubview:[self label:body size:14 weight:UIFontWeightRegular alpha:.76]];
    return panel;
}

- (UIView *)observePanel {
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:@"Today Weather" size:22 weight:UIFontWeightBold alpha:1]];
    [stack addArrangedSubview:[self label:@"Choose a date and sky. Saving the same date replaces that day, so the archive stays clean." size:13 weight:UIFontWeightRegular alpha:.68]];

    self.weatherDate = [UIDatePicker new];
    self.weatherDate.datePickerMode = UIDatePickerModeDate;
    self.weatherDate.maximumDate = NSDate.date;
    if (@available(iOS 14.0, *)) self.weatherDate.preferredDatePickerStyle = UIDatePickerStyleInline;
    [stack addArrangedSubview:self.weatherDate];

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 8;
    layout.itemSize = CGSizeMake(72, 74);
    self.grid = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.grid.backgroundColor = UIColor.clearColor;
    self.grid.dataSource = self;
    self.grid.delegate = self;
    [self.grid registerClass:MCSkyCell.class forCellWithReuseIdentifier:@"sky"];
    [self.grid.heightAnchor constraintEqualToConstant:246].active = YES;
    [stack addArrangedSubview:self.grid];

    self.force = [UISlider new];
    self.force.minimumValue = 1;
    self.force.maximumValue = 10;
    self.force.value = 6;
    [stack addArrangedSubview:[self label:@"Weather force" size:13 weight:UIFontWeightSemibold alpha:.65]];
    [stack addArrangedSubview:self.force];

    self.signals = [UITextField new];
    self.signals.placeholder = @"signals: work, family, health";
    self.signals.textColor = [UIColor colorWithWhite:.08 alpha:1];
    self.signals.backgroundColor = UIColor.whiteColor;
    self.signals.tintColor = MCBlue();
    self.signals.layer.cornerRadius = 14;
    self.signals.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    self.signals.leftViewMode = UITextFieldViewModeAlways;
    [self.signals.heightAnchor constraintEqualToConstant:46].active = YES;
    [stack addArrangedSubview:self.signals];

    self.memo = [UITextView new];
    self.memo.text = @"Optional note";
    self.memo.textColor = [UIColor colorWithWhite:.55 alpha:1];
    self.memo.backgroundColor = UIColor.whiteColor;
    self.memo.tintColor = MCBlue();
    self.memo.font = [UIFont systemFontOfSize:15];
    self.memo.layer.cornerRadius = 14;
    self.memo.delegate = self;
    [self.memo.heightAnchor constraintEqualToConstant:88].active = YES;
    [stack addArrangedSubview:self.memo];

    UIButton *save = [UIButton buttonWithType:UIButtonTypeSystem];
    [save setTitle:@"Log today's weather" forState:UIControlStateNormal];
    [save setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    save.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    save.backgroundColor = MCBlue();
    save.layer.cornerRadius = 18;
    [save.heightAnchor constraintEqualToConstant:52].active = YES;
    [save addTarget:self action:@selector(logWeather) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:save];

    UIButton *remove = [self plainButton:@"Delete selected day's weather" action:@selector(deletePickedWeather)];
    [stack addArrangedSubview:remove];

    self.status = [self label:@"Ready to observe." size:13 weight:UIFontWeightRegular alpha:.72];
    [stack addArrangedSubview:self.status];
    return panel;
}

- (UIView *)corridorPanel {
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:@"Weather Corridor" size:22 weight:UIFontWeightBold alpha:1]];

    UISegmentedControl *range = [[UISegmentedControl alloc] initWithItems:@[@"7D", @"14D", @"30D", @"All"]];
    range.selectedSegmentIndex = self.corridorDays == 7 ? 0 : self.corridorDays == 14 ? 1 : self.corridorDays == 30 ? 2 : 3;
    [range addTarget:self action:@selector(changeCorridorRange:) forControlEvents:UIControlEventValueChanged];
    [stack addArrangedSubview:range];

    [stack addArrangedSubview:[self label:[self corridorText] size:14 weight:UIFontWeightRegular alpha:.76]];
    return panel;
}

- (UIView *)mapPanel {
    MCClimatePeriod *period = self.engine.atlas.currentClimate;
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:@"Climate Map" size:22 weight:UIFontWeightBold alpha:1]];
    MCClimateMapView *map = [MCClimateMapView new];
    map.zone = period.mapZone;
    [map.heightAnchor constraintEqualToConstant:220].active = YES;
    [stack addArrangedSubview:map];
    [stack addArrangedSubview:[self label:[self mapTextFor:period] size:14 weight:UIFontWeightRegular alpha:.76]];
    return panel;
}

- (UIView *)lifePanel {
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:@"Life Chronicle" size:22 weight:UIFontWeightBold alpha:1]];
    [stack addArrangedSubview:[self label:@"Mark events and compare emotional climate before and after them." size:13 weight:UIFontWeightRegular alpha:.68]];

    self.lifeDate = [UIDatePicker new];
    self.lifeDate.datePickerMode = UIDatePickerModeDate;
    self.lifeDate.maximumDate = NSDate.date;
    if (@available(iOS 14.0, *)) self.lifeDate.preferredDatePickerStyle = UIDatePickerStyleCompact;
    [stack addArrangedSubview:self.lifeDate];

    UITextField *title = [UITextField new];
    title.placeholder = @"event title";
    title.textColor = [UIColor colorWithWhite:.08 alpha:1];
    title.backgroundColor = UIColor.whiteColor;
    title.layer.cornerRadius = 14;
    title.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    title.leftViewMode = UITextFieldViewModeAlways;
    title.tag = 41;
    [title.heightAnchor constraintEqualToConstant:46].active = YES;
    [stack addArrangedSubview:title];

    UITextField *detail = [UITextField new];
    detail.placeholder = @"detail, people, place";
    detail.textColor = [UIColor colorWithWhite:.08 alpha:1];
    detail.backgroundColor = UIColor.whiteColor;
    detail.layer.cornerRadius = 14;
    detail.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    detail.leftViewMode = UITextFieldViewModeAlways;
    detail.tag = 42;
    [detail.heightAnchor constraintEqualToConstant:46].active = YES;
    [stack addArrangedSubview:detail];

    UIButton *save = [UIButton buttonWithType:UIButtonTypeSystem];
    [save setTitle:@"Place life mark" forState:UIControlStateNormal];
    [save setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    save.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    save.backgroundColor = MCBlue();
    save.layer.cornerRadius = 18;
    [save.heightAnchor constraintEqualToConstant:52].active = YES;
    [save addTarget:self action:@selector(addLifeMark) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:save];

    self.status = [self label:@"Recent marks" size:13 weight:UIFontWeightSemibold alpha:.74];
    [stack addArrangedSubview:self.status];
    [stack addArrangedSubview:[self label:[self lifeText] size:14 weight:UIFontWeightRegular alpha:.76]];
    return panel;
}

- (UIView *)reportPanel {
    UIView *panel = [self panel];
    UIStackView *stack = [self stackIn:panel];
    [stack addArrangedSubview:[self label:@"Climate Report" size:22 weight:UIFontWeightBold alpha:1]];
    [stack addArrangedSubview:[self label:[self reportText] size:14 weight:UIFontWeightRegular alpha:.76]];

    UIButton *review = [UIButton buttonWithType:UIButtonTypeSystem];
    [review setTitle:@"Generate weekly review" forState:UIControlStateNormal];
    [review setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    review.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    review.backgroundColor = [UIColor colorWithRed:.44 green:.74 blue:.45 alpha:1];
    review.layer.cornerRadius = 18;
    [review.heightAnchor constraintEqualToConstant:52].active = YES;
    [review addTarget:self action:@selector(saveWeeklyReview) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:review];

    UIButton *export = [UIButton buttonWithType:UIButtonTypeSystem];
    [export setTitle:@"Export Markdown / PDF / Poster" forState:UIControlStateNormal];
    [export setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    export.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    export.backgroundColor = MCBlue();
    export.layer.cornerRadius = 18;
    [export.heightAnchor constraintEqualToConstant:52].active = YES;
    [export addTarget:self action:@selector(exportReport) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:export];

    UIButton *reset = [self plainButton:@"Reset local archive" action:@selector(confirmResetArchive)];
    [stack addArrangedSubview:reset];

    [stack addArrangedSubview:[self label:@"Saved Reviews" size:17 weight:UIFontWeightBold alpha:.95]];
    [stack addArrangedSubview:[self label:[self reviewArchiveText] size:14 weight:UIFontWeightRegular alpha:.76]];
    return panel;
}

- (UIButton *)plainButton:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:1 alpha:.82] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:.08];
    button.layer.cornerRadius = 16;
    [button.heightAnchor constraintEqualToConstant:46].active = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return MCWeatherAllKinds().count; }

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCSkyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sky" forIndexPath:indexPath];
    MCWeatherKind kind = [MCWeatherAllKinds()[indexPath.item] integerValue];
    cell.glyph.text = MCWeatherKindGlyph(kind);
    cell.name.text = MCWeatherKindTitle(kind);
    cell.contentView.layer.borderColor = kind == self.pickedKind ? MCBlue().CGColor : [UIColor colorWithWhite:1 alpha:.08].CGColor;
    cell.contentView.layer.borderWidth = kind == self.pickedKind ? 2 : 1;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.pickedKind = [MCWeatherAllKinds()[indexPath.item] integerValue];
    [collectionView reloadData];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Optional note"]) {
        textView.text = @"";
        textView.textColor = [UIColor colorWithWhite:.08 alpha:1];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (!textView.text.length) {
        textView.text = @"Optional note";
        textView.textColor = [UIColor colorWithWhite:.55 alpha:1];
    }
}

- (void)logWeather {
    NSString *memo = [self.memo.text isEqualToString:@"Optional note"] ? @"" : self.memo.text;
    NSDate *day = self.weatherDate.date ?: NSDate.date;
    [self.engine observeWeather:self.pickedKind force:lround(self.force.value) signals:[self signalWords] memo:memo day:day];
    self.status.text = @"Saved. The climate center has recalculated this date.";
    self.signals.text = @"";
    self.memo.text = @"Optional note";
    self.memo.textColor = [UIColor colorWithWhite:.55 alpha:1];
    [self.view endEditing:YES];
}

- (void)deletePickedWeather {
    NSDate *day = self.weatherDate.date ?: NSDate.date;
    [self.engine removeWeatherOnDay:day];
    self.status.text = @"Deleted selected day. The climate center has recalculated.";
    [self.view endEditing:YES];
}

- (void)changeCorridorRange:(UISegmentedControl *)sender {
    NSArray *days = @[@7, @14, @30, @0];
    self.corridorDays = [days[sender.selectedSegmentIndex] integerValue];
    [self reloadDeck];
}

- (NSArray<NSString *> *)signalWords {
    NSArray *raw = [self.signals.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",，;；"]];
    NSMutableArray *words = [NSMutableArray array];
    for (NSString *item in raw) {
        NSString *word = [item stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (word.length && ![words containsObject:word]) [words addObject:word];
    }
    return words;
}

- (void)addLifeMark {
    UITextField *title = [self.view viewWithTag:41];
    UITextField *detail = [self.view viewWithTag:42];
    NSString *name = title.text.length ? title.text : @"Life event";
    [self.engine markLife:name detail:detail.text ?: @"" day:self.lifeDate.date ?: NSDate.date];
    title.text = @"";
    detail.text = @"";
    [self.view endEditing:YES];
    [self reloadDeck];
}

- (void)confirmResetArchive {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset archive?" message:@"This removes all local weather and life marks on this device." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action) {
        [self.engine clearArchive];
        [self reloadDeck];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveWeeklyReview {
    NSString *body = [self weeklyReviewText];
    NSDateFormatter *formatter = [self day];
    NSString *title = [NSString stringWithFormat:@"Weekly Review · %@", [formatter stringFromDate:NSDate.date]];
    [self.engine saveReview:title body:body];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Weekly review saved" message:body preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        [self reloadDeck];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)bodyText {
    if (self.mode == MCDeckModeCorridor) return [self corridorText];
    if (self.mode == MCDeckModeStorm) return [self stormText];
    if (self.mode == MCDeckModeSunny) return [self sunnyText];
    return @"";
}

- (NSString *)corridorText {
    NSArray *allSkies = self.engine.atlas.vault.skies;
    NSArray *skies = self.corridorDays > 0 ? MCSkiesSince(allSkies, self.corridorDays) : allSkies;
    if (!skies.count) return @"No sky observed yet. Return to Today Weather to begin the corridor.";

    NSInteger week = MCAverage(MCSkiesSince(skies, 7));
    NSInteger twoWeeks = MCAverage(MCSkiesSince(skies, 14));
    NSInteger month = MCAverage(MCSkiesSince(skies, 30));
    NSInteger rough = MCRoughCount(MCSkiesSince(skies, 14));
    NSInteger clear = MCClearCount(MCSkiesSince(skies, 14));
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"7-day temperature: %ld°", (long)week]];
    [lines addObject:[NSString stringWithFormat:@"14-day temperature: %ld° · clear %ld · rough %ld", (long)twoWeeks, (long)clear, (long)rough]];
    [lines addObject:[NSString stringWithFormat:@"30-day baseline: %ld° · movement %@", (long)month, [self movementFrom:month to:week]]];
    [lines addObject:@"\nRecent skies"];

    NSDateFormatter *df = [self day];
    for (NSInteger i = 0; i < MIN(24, skies.count); i++) {
        MCWeatherSnapshot *sky = skies[i];
        NSString *signals = sky.signals.count ? [sky.signals componentsJoinedByString:@", "] : @"no signal";
        [lines addObject:[NSString stringWithFormat:@"%@  %@ %@ · force %ld · %@", [df stringFromDate:sky.day], sky.glyph, sky.title, (long)sky.force, signals]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

- (NSString *)stormText {
    NSArray *storms = self.engine.atlas.storms;
    NSArray *recent = MCSkiesSince(self.engine.atlas.vault.skies, 14);
    NSInteger rough = MCRoughCount(recent);
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"Current 14-day storm pressure: %ld/%lu rough skies", (long)rough, (unsigned long)MAX((NSUInteger)1, recent.count)]];
    [lines addObject:rough >= 5 ? @"Warning: pressure is clustering. Give the next few days lighter expectations." : @"No active storm cluster. Keep watching continuity, not one bad day."];
    if (!storms.count) {
        [lines addObject:@"\nNo archived storm event yet. 7 continuous rainstorm/thunder days form a Rainstorm Front; 14 days form a Long Thunder System."];
        return [lines componentsJoinedByString:@"\n"];
    }

    NSDateFormatter *df = [self day];
    [lines addObject:@"\nArchived systems"];
    for (MCStormEvent *storm in storms) {
        [lines addObject:[NSString stringWithFormat:@"%@ → %@ · %@ · %ld days · origin: %@", [df stringFromDate:storm.start], [df stringFromDate:storm.end], storm.name, (long)storm.span, storm.origin]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

- (NSString *)sunnyText {
    NSArray *epochs = self.engine.atlas.sunnyEpochs;
    NSInteger run = [self currentClearRun];
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"Current bright run: %ld days", (long)run]];
    [lines addObject:[NSString stringWithFormat:@"Next memorial threshold: %ld days left", (long)MAX(0, 30 - run)]];
    [lines addObject:run >= 7 ? @"Recovery is becoming visible. Keep the routine that supports this weather." : @"A clear epoch begins with small repeated days, not perfect days."];

    if (!epochs.count) {
        [lines addObject:@"\nNo golden epoch yet. 30 continuous sunny/cloudy days will be kept here as a life highlight."];
        return [lines componentsJoinedByString:@"\n"];
    }

    NSDateFormatter *df = [self day];
    [lines addObject:@"\nMemorials"];
    for (MCSunnyEpoch *epoch in epochs) [lines addObject:[NSString stringWithFormat:@"%@ → %@ · Clear epoch · %ld days", [df stringFromDate:epoch.start], [df stringFromDate:epoch.end], (long)epoch.span]];
    return [lines componentsJoinedByString:@"\n"];
}

- (NSString *)lifeText {
    NSArray *marks = self.engine.atlas.vault.lifeMarks;
    if (!marks.count) return @"No life event yet. Place an offer, move, breakup, marriage, startup or any personal landmark.";

    NSMutableArray *lines = [NSMutableArray array];
    NSDateFormatter *df = [self day];
    for (NSDictionary *mark in marks) {
        NSDate *day = [NSDate dateWithTimeIntervalSince1970:[mark[@"day"] doubleValue]];
        NSInteger before = [self averageFrom:day offset:-14 length:14];
        NSInteger after = [self averageFrom:day offset:0 length:14];
        NSString *delta = before && after ? [self movementFrom:before to:after] : @"needs more nearby skies";
        [lines addObject:[NSString stringWithFormat:@"%@ · %@\nimpact: %@%@", [df stringFromDate:day], mark[@"title"] ?: @"Life event", delta, [mark[@"detail"] length] ? [NSString stringWithFormat:@"\nnote: %@", mark[@"detail"]] : @""]];
    }
    return [lines componentsJoinedByString:@"\n\n"];
}

- (NSString *)mapTextFor:(MCClimatePeriod *)period {
    NSDictionary *signals = [self signalCount];
    NSArray *keys = [signals keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) { return [b compare:a]; }];
    NSMutableArray *belts = [NSMutableArray array];
    for (NSInteger i = 0; i < MIN(5, keys.count); i++) [belts addObject:[NSString stringWithFormat:@"%@ (%@)", keys[i], signals[keys[i]]]];
    NSString *top = belts.count ? [belts componentsJoinedByString:@", "] : @"No signal belt yet";
    return [NSString stringWithFormat:@"Current area: %@\nStrongest signal belts: %@\nClear Region rises with sunny days. Pressure Zone grows when rough weather appears repeatedly, not from one isolated day.", period.mapZone, top];
}

- (NSString *)reportText {
    MCClimatePeriod *period = self.engine.atlas.currentClimate;
    NSArray *skies = self.engine.atlas.vault.skies;
    NSArray *week = MCSkiesSince(skies, 7);
    NSArray *month = MCSkiesSince(skies, 30);
    NSInteger clearRate = skies.count ? MCClearCount(skies) * 100 / skies.count : 0;
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"Season: %@", period.seasonName]];
    [lines addObject:[NSString stringWithFormat:@"Climate: %@", period.climateName]];
    [lines addObject:[NSString stringWithFormat:@"Temperature: %ld° · stability %ld/100", (long)period.temperature, (long)period.calmIndex]];
    [lines addObject:[NSString stringWithFormat:@"Weekly reading: %ld° · %@", (long)MCAverage(week), [self movementFrom:MCAverage(month) to:MCAverage(week)]]];
    [lines addObject:[NSString stringWithFormat:@"Monthly baseline: %ld° · rough %ld · clear %ld", (long)MCAverage(month), (long)MCRoughCount(month), (long)MCClearCount(month)]];
    [lines addObject:[NSString stringWithFormat:@"Clear sky ratio: %ld%%", (long)clearRate]];
    [lines addObject:[NSString stringWithFormat:@"Storm archives: %lu · clear memorials: %lu", (unsigned long)self.engine.atlas.storms.count, (unsigned long)self.engine.atlas.sunnyEpochs.count]];
    [lines addObject:[NSString stringWithFormat:@"Observed skies: %lu", (unsigned long)skies.count]];
    [lines addObject:[NSString stringWithFormat:@"Next review: %@", skies.count < 7 ? @"record at least 7 days for a weekly climate report" : @"compare this week with the monthly baseline"]];
    return [lines componentsJoinedByString:@"\n"];
}

- (NSString *)weeklyReviewText {
    NSArray *skies = self.engine.atlas.vault.skies;
    NSArray *week = MCSkiesSince(skies, 7);
    NSArray *month = MCSkiesSince(skies, 30);
    if (!week.count) return @"No sky has been logged this week. Add one weather record first, then generate a review.";

    NSDictionary *signals = [self signalCountInSkies:week];
    NSArray *keys = [signals keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) { return [b compare:a]; }];
    NSString *mainSignal = keys.count ? keys.firstObject : @"no dominant signal";
    NSInteger weekTemp = MCAverage(week);
    NSInteger monthTemp = MCAverage(month);
    NSString *motion = [self movementFrom:monthTemp to:weekTemp];
    NSInteger rough = MCRoughCount(week);
    NSInteger clear = MCClearCount(week);

    NSString *focus = rough >= 3 ? @"reduce load and protect recovery time" : clear >= 4 ? @"keep the routine that supported clearer weather" : @"watch which signals repeat before reacting to one day";
    return [NSString stringWithFormat:@"This week held %lu skies. Temperature: %ld°. Compared with the 30-day baseline, the climate is %@. Clear skies: %ld. Rough skies: %ld. Main signal: %@. Suggested focus: %@.", (unsigned long)week.count, (long)weekTemp, motion, (long)clear, (long)rough, mainSignal, focus];
}

- (NSString *)reviewArchiveText {
    NSArray *reviews = self.engine.atlas.vault.reviews;
    if (!reviews.count) return @"No saved review yet. Tap Generate weekly review to turn the current pattern into a saved reflection.";
    NSMutableArray *lines = [NSMutableArray array];
    NSDateFormatter *formatter = [self day];
    for (NSInteger i = 0; i < MIN(6, reviews.count); i++) {
        NSDictionary *review = reviews[i];
        NSDate *day = [NSDate dateWithTimeIntervalSince1970:[review[@"day"] doubleValue]];
        [lines addObject:[NSString stringWithFormat:@"%@ · %@\n%@", [formatter stringFromDate:day], review[@"title"] ?: @"Weekly Review", review[@"body"] ?: @""]];
    }
    return [lines componentsJoinedByString:@"\n\n"];
}

- (NSDictionary *)signalCountInSkies:(NSArray<MCWeatherSnapshot *> *)skies {
    NSMutableDictionary *bag = [NSMutableDictionary dictionary];
    for (MCWeatherSnapshot *sky in skies) {
        for (NSString *word in sky.signals) bag[word] = @([bag[word] integerValue] + 1);
    }
    return bag;
}

- (NSDictionary *)signalCount {
    NSMutableDictionary *bag = [NSMutableDictionary dictionary];
    for (MCWeatherSnapshot *sky in self.engine.atlas.vault.skies) {
        for (NSString *word in sky.signals) bag[word] = @([bag[word] integerValue] + 1);
    }
    return bag;
}

- (NSInteger)currentClearRun {
    NSInteger run = 0;
    NSDate *previous = nil;
    NSCalendar *calendar = NSCalendar.currentCalendar;
    NSArray *oldest = [self.engine.atlas.vault.skies sortedArrayUsingComparator:^NSComparisonResult(MCWeatherSnapshot *a, MCWeatherSnapshot *b) { return [a.day compare:b.day]; }];
    for (MCWeatherSnapshot *sky in oldest) {
        BOOL clear = sky.kind == MCWeatherKindSunny || sky.kind == MCWeatherKindCloudy;
        BOOL touches = !previous || [calendar components:NSCalendarUnitDay fromDate:[calendar startOfDayForDate:previous] toDate:[calendar startOfDayForDate:sky.day] options:0].day == 1;
        run = clear && touches ? run + 1 : (clear ? 1 : 0);
        previous = sky.day;
    }
    return run;
}

- (NSInteger)averageFrom:(NSDate *)day offset:(NSInteger)offset length:(NSInteger)length {
    NSDate *start = [day dateByAddingTimeInterval:offset * 24 * 3600];
    NSDate *end = [start dateByAddingTimeInterval:length * 24 * 3600];
    NSMutableArray *slice = [NSMutableArray array];
    for (MCWeatherSnapshot *sky in self.engine.atlas.vault.skies) {
        if ([sky.day compare:start] != NSOrderedAscending && [sky.day compare:end] == NSOrderedAscending) [slice addObject:sky];
    }
    return MCAverage(slice);
}

- (NSString *)movementFrom:(NSInteger)base to:(NSInteger)now {
    if (!base || !now) return @"insufficient data";
    NSInteger delta = now - base;
    if (delta > 8) return [NSString stringWithFormat:@"warming +%ld°", (long)delta];
    if (delta < -8) return [NSString stringWithFormat:@"cooling %ld°", (long)delta];
    return @"stable range";
}

- (NSDateFormatter *)day {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy.MM.dd";
    return formatter;
}

- (void)exportReport {
    MCClimatePeriod *climate = self.engine.atlas.currentClimate;
    NSString *markdown = [self.engine.atlas.forge markdownForSkies:self.engine.atlas.vault.skies climate:climate storms:self.engine.atlas.storms sunny:self.engine.atlas.sunnyEpochs];
    NSURL *md = [self.engine.atlas.forge writeMarkdown:markdown];
    NSURL *pdf = [self.engine.atlas.forge writePDF:markdown];
    UIImage *poster = [self.engine.atlas.forge posterWithText:markdown size:CGSizeMake(900, 1200)];
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[md, pdf, poster] applicationActivities:nil];
    if (share.popoverPresentationController) {
        share.popoverPresentationController.sourceView = self.view;
        share.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 1, 1);
    }
    [self presentViewController:share animated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskPortrait; }
@end
