//
//  MSPhotoSelector.m
//  feedback
//
//  Created by lee on 2017/5/31.
//  Copyright © 2017年 mjsfax. All rights reserved.
//

#import "MSPhotoSelector.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MSAlert.h"
#import "FileManager.h"
#define imageWH 48
#define MARGIN 16

@interface MSPhotoSelector()<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSInteger editTag;
}
@property (assign, nonatomic) NSInteger maxImageCount;

@end

@implementation MSPhotoSelector

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.maxImageCount = 4;//([UIScreen mainScreen].bounds.size.width - MARGIN) / (imageWH+MARGIN);
        UIButton *btn = [self createButtonWithImage:[UIImage imageNamed:@"ms_addimg"] selector:@selector(addNewButton:)];
        [btn setImage:[UIImage imageNamed:@"ms_addimg_pressed"] forState:UIControlStateHighlighted];
        if (btn) {
            [self addSubview:btn];
        }
    }
    return self;
}

- (UIButton *)createButtonWithImage:(UIImage *)image selector:(SEL)selector {
    
    if (!image) {
        return nil;
    }
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setImage:image forState:UIControlStateNormal];
    [addBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    addBtn.tag = self.subviews.count;
    
    if (addBtn.tag != 0) {
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [addBtn addGestureRecognizer:gesture];
    }
    return addBtn;
}

- (void)addNewButton:(UIButton *)btn {
    
    if (![self deleteClose:btn]) {
        editTag = -1;
        [self chooseImageSource];
    }
}

- (void)chooseImageSource {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self picture];
    }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self camera];
    }];
    [alertController addAction:album];
    [alertController addAction:camera];
    [alertController addAction:cancel];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)changeOld:(UIButton *)btn {
    
    if (![self deleteClose:btn]) {
        editTag = btn.tag;
        [self chooseImageSource];
    }
}

- (void)longPress:(UIGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIButton *btn = (UIButton *)gesture.view;
        UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
        delete.bounds = CGRectMake(0, 0, 15, 15);
        [delete setBackgroundImage:[UIImage imageNamed:@"ms_delete_highlighted"] forState:UIControlStateNormal];
        [delete addTarget:self action:@selector(deletePicture:) forControlEvents:UIControlEventTouchUpInside];
        delete.frame = CGRectMake(btn.frame.size.width-delete.frame.size.width, 0, delete.frame.size.width, delete.frame.size.height);
        [btn addSubview:delete];
    }
    
}

- (void)deletePicture:(UIButton *)btn {
    
    UIButton *superBtn = (UIButton *)btn.superview;
    [FileManager deleteFile:[self getImagePath:(int)superBtn.tag]];
    
    [btn.superview removeFromSuperview];
    if ([[self.subviews lastObject] isHidden]) {
        [[self.subviews lastObject] setHidden:NO];
    }
    
}

- (BOOL)deleteClose:(UIButton *)btn {
    
    if (btn.subviews.count == 2) {
        [[btn.subviews lastObject] removeFromSuperview];
        return YES;
    }
    return NO;
}

- (void)picture {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        [MSAlert showWithTitle:@"提示" message:@"没有权限访问" buttonClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self.window.rootViewController presentViewController:picker animated:YES completion:nil];
    
}

- (void)camera {

    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        [MSAlert showWithTitle:@"提示" message:@"没有权限访问" buttonClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    picker.delegate = self;
    [self.window.rootViewController presentViewController:picker animated:YES completion:nil];

}


#pragma mark - delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        return;
    }
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    if (editTag == -1) {
        UIButton *btn = [self createButtonWithImage:image selector:@selector(changeOld:)];
        if (!btn) {
            return;
        }
        [self insertSubview:btn atIndex:self.subviews.count-1];
        [FileManager saveData:data toFile:[self getImagePath:(int)btn.tag]];
        if (self.subviews.count-1 == self.maxImageCount) {
            [[self.subviews lastObject] setHidden:YES];
        }
        
    } else {
        
        UIButton *btn = (UIButton *)[self viewWithTag:editTag];
        [FileManager deleteFile:[self getImagePath:(int)btn.tag]];
        [btn setImage:image forState:UIControlStateNormal];
        [FileManager saveData:data toFile:[self getImagePath:(int)btn.tag]];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    NSInteger count = self.subviews.count;
    for (int i = 0; i<count; i++) {
        UIButton *btn = self.subviews[i];
        CGFloat x = i * (imageWH + 8);
        btn.frame = CGRectMake(x, 0, imageWH, imageWH);
    }
    
}

- (NSString *)getImagePath:(int)tag {
    NSString *fileName = [NSString stringWithFormat:@"%d.jpg",tag];
    NSString *filePath = [[FileManager getFeedbackDirPath] stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
