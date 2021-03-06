//
//  JoyTextViewCell.m
//  Pods
//
//  Created by wangguopeng on 2017/8/11.
//
//
#define KTEXTMaXWIDTH  SCREEN_W - 110
#define KTEXTMaXHEIGHT 200
#define KTEXTMINHEIGHT 34
#define KTEXTTBSPACE  10

#import "JoyTextViewCell.h"
#import "JoyCellBaseModel.h"
#import "NSString+JoyCategory.h"
#import "joy.h"
@interface JoyTextViewCell()<UITextViewDelegate>
//@property (weak, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UITextView *textView;
//@property (weak, nonatomic)  NSLayoutConstraint *textViewHConstraint;

@property (nonatomic,copy) NSString *inputOldStr;
@property (nonatomic,copy)NSString *changeTextKey;
//@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (nonatomic,assign)BOOL isNeedScroll;
@end

@implementation JoyTextViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textView];
        [self setConstraint];
        [self updateConstraintsIfNeeded];
    }
    return self;
}

-(UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:CGRectZero];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:15];
    }
    return _textView;
}

//-(UILabel *)titleLabel{
//    if(!_titleLabel){
//        _titleLabel =[[UILabel alloc]init];
//        _titleLabel.font = [UIFont systemFontOfSize:15];
//        _titleLabel.numberOfLines = 0;
//    }
//    return _titleLabel;
//}
//
-(void)setConstraint{
    __weak __typeof(&*self)weakSelf = self;
//    MAS_CONSTRAINT(self.titleLabel,
//                   make.leading.mas_equalTo(weakSelf.contentView).offset(15);
//                   make.width.mas_lessThanOrEqualTo(80);
//                   make.top.mas_equalTo(weakSelf.contentView.mas_top).offset(5);
//                   make.centerY.mas_equalTo(weakSelf.contentView.mas_centerY);
//                   );
    
    MAS_CONSTRAINT(self.textView,
                   make.leading.mas_equalTo(weakSelf.contentView).offset(5);
                   make.trailing.mas_equalTo(weakSelf.contentView).offset(-15);
                   make.height.mas_greaterThanOrEqualTo(33.5);
                   make.top.mas_equalTo(weakSelf.contentView.mas_top).offset(5);
                   make.centerY.mas_equalTo(weakSelf.contentView.mas_centerY);
                   );
}

- (void)setCellWithModel:(JoyTextCellBaseModel *)model{
    self.textView.returnKeyType = UIReturnKeyDone;
    objc_setAssociatedObject(self, @selector(changeFrameWhenTextViewChanged:), model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.changeTextKey = model.changeKey;
    self.textView.keyboardType = model.keyboardType?model.keyboardType:UIKeyboardTypeDefault;
    self.maxNum = model.maxNumber;
//    self.titleLabel.text = model.title;
    if (self.maxNum && model.subTitle.strLength> self.maxNum)
    {
        model.subTitle  =  [model.subTitle subToMaxIndex:self.maxNum];
    }
    self.textView.text = model.subTitle;
//    self.placeHolderLabel.text = model.placeHolder;
//    self.placeHolderLabel.hidden = self.textView.text.length;
//    if (model.titleColor) {self.titleLabel.textColor = model.titleColor;}
    CGSize constraintSize = CGSizeMake(KTEXTMaXWIDTH, MAXFLOAT);
    CGSize size = [self.textView sizeThatFits:constraintSize];
    if (size.height >= KTEXTMaXHEIGHT)
    {
        size.height = KTEXTMaXHEIGHT;
    }
    else if (size.height<=KTEXTMINHEIGHT)
    {
        size.height = KTEXTMINHEIGHT;
    }
//    self.textViewHConstraint.constant = size.height;
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(size.height);
    }];
    self.contentView.height = size.height+11;
    [self setNeedsUpdateConstraints];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(textshouldBeginEditWithTextContainter:andIndexPath:)])
    {
        [self.delegate textshouldBeginEditWithTextContainter:textView andIndexPath:self.index];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(textshouldEndEditWithTextContainter:andIndexPath:)])
    {
        [self.delegate textshouldEndEditWithTextContainter:textView andIndexPath:self.index];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    
    if ([self.delegate respondsToSelector:@selector(textHasChanged:andText:andChangedKey:)]) {
        [self.delegate textHasChanged:self.index andText:textView.text andChangedKey:self.changeTextKey];
    }
    if (self.maxNum) {
        UITextPosition* beginning = textView.beginningOfDocument;
        UITextRange* markedTextRange = textView.markedTextRange;
        UITextPosition* selectionStart = markedTextRange.start;
        UITextPosition* selectionEnd = markedTextRange.end;
        NSInteger location = [textView offsetFromPosition:beginning toPosition:selectionStart];
        NSInteger length = [textView offsetFromPosition:selectionStart toPosition:selectionEnd];
        NSRange tRange = NSMakeRange(location,length);
        NSString *newString = [textView.text substringWithRange:tRange];
        NSString *oldString = [textView.text stringByReplacingOccurrencesOfString:newString withString:@"" options:0 range:tRange];
        if(newString.length <= 0)//非汉字输入
        {
            if (textView.text.strLength > self.maxNum)
            {textView.text = self.inputOldStr;}
            else
            {self.inputOldStr = textView.text;}
        }
        else//汉字输入
        {
            NSInteger tNewNumber = newString.strLength;
            NSInteger tOldNumber = oldString.strLength;
            BOOL isEnsure = (newString.length*2 == tNewNumber);//判断markedText是汉字还是字母。如果是汉字，说是用户最终输入。
            if(isEnsure && tNewNumber+tOldNumber > self.maxNum)
            {
                NSInteger tIndex = (tNewNumber+tOldNumber) - self.maxNum;
                tIndex = tNewNumber - tIndex;
                tIndex /= 2;
                NSString *finalStr = [oldString substringToIndex:location];
                finalStr = [finalStr stringByAppendingString:[newString substringToIndex:tIndex]];
                finalStr = [finalStr stringByAppendingString:[oldString substringFromIndex:location]];
                textView.text = finalStr;
            }
        }
    }
//    self.placeHolderLabel.hidden = textView.text.length;
    [self changeFrameWhenTextViewChanged:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(textChanged:andText:andChangedKey:)]) {
        JoyTextCellBaseModel *model = objc_getAssociatedObject(self, @selector(changeFrameWhenTextViewChanged:));
        model.subTitle = textView.text;
        [self.delegate textChanged:self.index andText:textView.text andChangedKey:self.changeTextKey];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if(range.length == 1)
    {return YES;}
    if ((range.location == 0 && [text isEqualToString:@" "]) || [text isEqualToString:@"\n"])
    {return NO;}
    return YES;
}

- (void)changeFrameWhenTextViewChanged:(UITextView *)textView{
    //    [textView flashScrollIndicators];   // 闪动滚动条
    CGSize constraintSize = CGSizeMake(textView.contentSize.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= KTEXTMaXHEIGHT)
    {
        size.height = KTEXTMaXHEIGHT;
    }
    else if (size.height<=KTEXTMINHEIGHT)
    {
        size.height = KTEXTMINHEIGHT;
    }
    
    if (self.contentView.height-KTEXTTBSPACE != size.height) {
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_greaterThanOrEqualTo(size.height);
        }];

//        self.textViewHConstraint.constant = size.height;
//        self.contentView.height = size.height+KTEXTTBSPACE;
        JoyTextCellBaseModel *model = objc_getAssociatedObject(self, @selector(changeFrameWhenTextViewChanged:));
        model.cellH = self.contentView.height;
        [self setNeedsUpdateConstraints];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.scrollBlock?self.scrollBlock(self.index,UITableViewScrollPositionBottom,NO):nil;
            self.beginUpdatesBlock?self.beginUpdatesBlock():nil;
            self.endUpdatesBlock?self.endUpdatesBlock():nil;
        });
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
    if (scrollView == self.textView) {
        CGSize constraintSize = CGSizeMake(scrollView.contentSize.width, MAXFLOAT);
        CGSize size = [scrollView sizeThatFits:constraintSize];
        CGFloat contentOfSetY = size.height-scrollView.height;
        scrollView.contentOffset.y != contentOfSetY?[scrollView setContentOffset:CGPointMake(0, contentOfSetY)]:nil;
    }
    
}

@end
