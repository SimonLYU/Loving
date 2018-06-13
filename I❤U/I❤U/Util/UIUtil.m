//
//  UIUtil+TT.m
//  TT
//
//  Created by daixiang on 15/2/13.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import "StringUtil.h"
#import "SystemUtil.h"
#import "UIUtil.h"
#import "TTTipView.h"
//#import "Constants.h"

@interface UIUtil ()



@end

static UITextView *textViewForHeightCalculation = nil;

@implementation UIUtil

+ (void)initialize {
    textViewForHeightCalculation = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    textViewForHeightCalculation.textContainer.lineFragmentPadding = 0;
    textViewForHeightCalculation.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

+ (void)showHint:(NSString *)text {
    [UIUtil showHint:text inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showHint:(NSString *)text inView:(UIView *)view {
    TTTipView *tipView = [TTTipView tipViewWithType:TTTipViewTypeTextHint];
    TTTipViewAnimationOptions options = TTTipViewAnimationOptionFadeInOut | TTTipViewAnimationOptionScaleInOut | TTTipViewAnimationOptionGrowth;
    [tipView setText:text];
    [tipView showInView:view animated:YES animationOptions:options];
}

+ (void)showLoading {
    [UIUtil showLoadingWithText:nil];
}

+ (void)showLoadingWithText:(NSString *)text {
    [UIUtil showLoadingWithText:text inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showLoadingWithText:(NSString *)text inView:(UIView *)view {
    
    TTTipView *tipView = [TTTipView tipViewWithType:TTTipViewTypeLoading];
    TTTipViewAnimationOptions options = TTTipViewAnimationOptionFadeInOut | TTTipViewAnimationOptionScaleInOut | TTTipViewAnimationOptionGrowth;
    [tipView setText:text];
//    NSLog(@"showloading %p", tipView);
    [tipView showInView:[UIApplication sharedApplication].keyWindow animated:YES animationOptions:options];
}

+ (void)dismissLoading {
    
    TTTipView *tipView = [TTTipView currentTipView];
    
    // 这里要做类型判断，否则没有执行顺序有问题的时候，可能dismiss错误的view
    // 比如showLoading->showError->dissmissLoading
    if (tipView.tipType == TTTipViewTypeLoading) {
        [TTTipView dismissCurrentTipViewAnimated:YES];
    }
}

+ (void)showError:(NSError *)error {
    [UIUtil showError:error withMessage:nil];
}

+ (void)showError:(NSError *)error withMessage:(NSString *)message {
//    if ([StringUtil isBlank:message]) {
    
        NSString *errMessage = [error localizedDescription];
        if ([StringUtil isBlank:errMessage] || [errMessage isEqualToString:@"系统繁忙"]) {
            errMessage = [UIUtil getLocalErrMessage:error];
        }
//    }
    
    if ([message length] == 0) {
        message = errMessage;
    } else {
        message = [NSString stringWithFormat:@"%@:%@", message, errMessage];
    }
    
    message = [NSString stringWithFormat:@"%@(%ld)", message, (long)[error code]];
    [UIUtil showHint:message];
}

+ (void)showErrorMessage:(NSString *)message
{
    [UIUtil showHint:NSLocalizedString(message,nil)];
}



+ (CGSize)calculateTextViewSizeForString:(NSString *)string withFont:(UIFont *)font inSize:(CGSize)size {
    
    textViewForHeightCalculation.attributedText = nil;
    textViewForHeightCalculation.font = font;
    textViewForHeightCalculation.text = string;
    return [textViewForHeightCalculation sizeThatFits:size];
}

+ (CGSize)calculateTextViewSizeForAttributedString:(NSAttributedString *)string inSize:(CGSize)size {
    
    textViewForHeightCalculation.text = nil;
    textViewForHeightCalculation.attributedText = string;
    return [textViewForHeightCalculation sizeThatFits:size];
}

#pragma mark - private

+ (NSString *)getLocalErrMessage:(NSError *)error{
    
    NSInteger errCode = error.code;
//    if ([error.domain isEqualToString:TTErrorDomain]) {
//
//        switch (errCode) {
//            case ERR_SYS:
//                return NSLocalizedString(@"err_def_sys", nil);
//            case ERR_SESSION_EXPIRED:
//                return NSLocalizedString(@"err_def_session_expired", nil);
//            case ERR_TIMEOUT:
//                return NSLocalizedString(@"err_def_timeout", nil);
//            case ERR_PB_PARSE:
//                return NSLocalizedString(@"err_def_pb_parse", nil);
//            case ERR_PARAM:
//                return NSLocalizedString(@"err_def_param", nil);
//            case ERR_NETWORK:
//                return NSLocalizedString(@"err_def_network", nil);
//            case ERR_DB_ERROR:
//                return NSLocalizedString(@"err_def_db_error", nil);
//            case ERR_NETSERVICE:
//                return NSLocalizedString(@"err_def_netservice", nil);
//            case ERR_NOT_LOGIN:
//                return NSLocalizedString(@"err_def_not_login", nil);
//            case ERR_FILE_NOT_FOUND:
//                return NSLocalizedString(@"err_def_file_not_found", nil);
//            case ERR_STILL_WAITING_RESPONSE:
//                return NSLocalizedString(@"err_def_waiting_response", nil);
//            case ERR_FACE_BIG_DOWNLOADING:
//                return NSLocalizedString(@"err_def_face_big_downloading", nil);
//            case ERR_IM_UPLOAD_ATTACHMENT_FAILED:
//                return NSLocalizedString(@"err_def_im_upload_attachment_failed", nil);
//            case ERR_IM_DOWNLOAD_ATTACHMENT_FAILED:
//                return NSLocalizedString(@"err_def_im_download_attachment_failed", nil);
//            case ERR_GAME_NO_LOCAL_PACKAGE:
//                return NSLocalizedString(@"err_def_game_no_local_package", nil);
//            case ERR_GAME_DOWNLOAD_HTTP_ERROR:
//                return NSLocalizedString(@"err_def_game_download_error", nil);
//            case ERR_ACCOUNT_PHONE_EXIST:
//                return NSLocalizedString(@"err_def_account_phone_exist", nil);
//            case ERR_ACCOUNT_USERNAME_EXIST:
//                return NSLocalizedString(@"err_def_account_username_exist", nil);
//            case ERR_ACCOUNT_NOT_EXIST:
//                return NSLocalizedString(@"err_def_account_not_exist", nil);
//            case ERR_ACCOUNT_PASSWORD_WRONG:
//                return NSLocalizedString(@"err_def_account_password_wrong", nil);
//            case ERR_ACCOUNT_ALIAS_MODIFIED:
//                return NSLocalizedString(@"err_def_account_alias_modified", nil);
//            case ERR_ACCOUNT_COMPLETED:
//                return NSLocalizedString(@"err_def_account_completed", nil);
//            case ERR_ACCOUNT_NO_HEAD_IMAGE:
//                return NSLocalizedString(@"err_def_account_no_head_image", nil);
//            case ERR_ACCOUNT_VERIFY_CODE_WRONG:
//                return NSLocalizedString(@"err_def_account_verify_code_wrong", nil);
//            case ERR_ACCOUNT_PASSWORD_SAME:
//                return NSLocalizedString(@"err_def_account_password_same", nil);
//            case ERR_ACCOUNT_PHONE_FORMAT_WRONG:
//                return NSLocalizedString(@"err_def_account_phone_format_wrong", nil);
//            case ERR_ACCOUNT_USERNAME_FORMAT_WRONG:
//                return NSLocalizedString(@"err_def_account_username_format_wrong", nil);
//            case ERR_ACCOUNT_PERMISSION_DENIED:
//                return NSLocalizedString(@"err_def_account_permission_denied", nil);
//            case ERR_ACCOUNT_HAS_NO_GUILD:
//                return NSLocalizedString(@"err_def_account_has_no_guild", nil);
//            case ERR_ACCOUNT_VERIFY_TOO_FREQ:
//                return NSLocalizedString(@"err_def_account_verify_too_freq", nil);
//            case ERR_ACCOUNT_EXIST:
//                return NSLocalizedString(@"err_def_account_exist", nil);
//            case ERR_SEND_MSG_TARGET_NOT_EXIST:
//                return NSLocalizedString(@"err_def_im_target_not_exist", nil);
//            case ERR_SEND_MSG_TARGET_NOT_FRIEND:
//                return NSLocalizedString(@"err_def_im_target_not_friend", nil);
//            case ERR_SEND_MSG_TIMELINE_SVR_FAILED:
//                return NSLocalizedString(@"err_def_im_timeline_svr_failed", nil);
//            case ERR_SEND_MSG_UPLOAD_ATTACHMENT_SVR_FAILED:
//                return NSLocalizedString(@"err_def_im_upload_attachment_svr_failed", nil);
//            case ERR_SEND_MSG_DOWNl_ATTACHMENT_SVR_FAILED:
//                return NSLocalizedString(@"err_def_im_download_attachment_svr_failed", nil);
//            case ERR_SEND_MSG_DOWNl_ATTACHMENT_EXCEED:
//                return NSLocalizedString(@"err_def_im_download_attachment_exceed", nil);
//            case ERR_SEND_MSG_ATTACHMENT_INVALID:
//                return NSLocalizedString(@"err_def_im_attachment_invalid", nil);
//            case ERR_SEND_MSG_ATTACHMENT_INVALID_UPLOAD_ALREADY:
//                return NSLocalizedString(@"err_def_im_attachment_invalid_upload_already", nil);
//            case ERR_SEND_MSG_ATTACHMENT_GEN_SMALL_IMG_FAILED:
//                return NSLocalizedString(@"err_def_im_attachment_gen_thumb_failed", nil);
//            case ERR_SEND_MSG_NOT_GROUP_MEMBER:
//                return NSLocalizedString(@"err_def_im_not_group_member", nil);
//            case ERR_SEND_MSG_UPDATE_GROUP_MSG_FAILED:
//                return NSLocalizedString(@"err_def_im_update_group_msg_failed", nil);
//            case ERR_SEND_MSG_PARAS_ERR:
//                return NSLocalizedString(@"err_def_im_param_err", nil);
//            case ERR_SEND_MSG_MUTE:
//                return NSLocalizedString(@"err_def_im_mute", nil);
//            case ERR_SEND_MSG_ALL_MUTE:
//                return NSLocalizedString(@"err_def_im_all_mute", nil);
//            case ERR_SEND_MSG_BUILD_SYSTEM_MSG_ERR:
//                return NSLocalizedString(@"err_def_im_build_sys_msg_err", nil);
//            case ERR_FRIEND_ALREADY_FRIEND:
//                return NSLocalizedString(@"err_def_friend_already_friend", nil);
//            case ERR_FRIEND_TARGET_NOT_FRIEND:
//                return NSLocalizedString(@"err_def_friend_target_not_friend", nil);
//            case ERR_FRIEND_VERIFY_FRIEND_FAILED:
//                return NSLocalizedString(@"err_def_friend_verify_friend_failed", nil);
//            case ERR_FRIEND_VERIFY_MSG_EXCEED:
//                return NSLocalizedString(@"err_def_friend_verify_msg_exceed", nil);
//            case ERR_FRIEND_DEL_NOT_SUPPORTED:
//                return NSLocalizedString(@"err_def_friend_del_not_supported", nil);
//            case ERR_FRIEND_CANNOT_ADD_YOURSEFL:
//                return NSLocalizedString(@"err_def_friend_cannot_add_yourself", nil);
//            case ERR_FRIEND_UPDATE_REMARK_FAILED:
//                return NSLocalizedString(@"err_def_friend_update_remark_failed", nil);
//            case ERR_GUILD_NAME_EXIST:
//                return NSLocalizedString(@"err_def_guild_name_exist", nil);
//            case ERR_GUILD_NOT_EXIST:
//                return NSLocalizedString(@"err_def_guild_not_exist", nil);
//            case ERR_GUILD_SHORT_ID_SET:
//                return NSLocalizedString(@"err_def_guild_short_id_set", nil);
//            case ERR_GUILD_SHORT_ID_EXIST:
//                return NSLocalizedString(@"err_def_guild_short_id_exist", nil);
//            case ERR_GUILD_USER_HAVE:
//                return NSLocalizedString(@"err_def_guild_user_in_guild", nil);
//            case ERR_GUILD_NO_PERMISSION:
//                return NSLocalizedString(@"err_def_guild_no_permission", nil);
//            case ERR_GUILD_APPLY_EXIST:
//                return NSLocalizedString(@"err_def_guild_apply_exist", nil);
//            case ERR_GUILD_APPLY_HAVE_REVIEWED:
//                return NSLocalizedString(@"err_def_guild_apply_have_reviewed", nil);
//            case ERR_GUILD_APPLY_HAVE_CONFIRMED:
//                return NSLocalizedString(@"err_def_guild_apply_have_confirmed", nil);
//            case ERR_GUILD_MEMBER_NOT_EXIST:
//                return NSLocalizedString(@"err_def_guild_member_not_exist", nil);
//            case ERR_GUILD_APPLY_NOT_EXIST:
//                return NSLocalizedString(@"err_def_guild_apply_not_exist", nil);
//            case ERR_GROUP_MEMBER_NOT_EXIST:
//                return NSLocalizedString(@"err_def_guild_group_member_not_exist", nil);
//            case ERR_GROUP_MEMBER_EXIST:
//                return NSLocalizedString(@"err_def_guild_group_member_exist", nil);
//            case ERR_GROUP_NOT_EXIST:
//                return NSLocalizedString(@"err_def_guild_group_not_exist", nil);
//            case ERR_GROUP_OWNER_CANNOT_BE_REMOVED:
//                return NSLocalizedString(@"err_def_guild_group_owner_cannot_quit", nil);
//            case ERR_GUILD_OWNER_CANNOT_BE_REMOVED:
//                return NSLocalizedString(@"err_def_guild_guild_owner_cannot_quit", nil);
//            case ERR_GROUP_CANNOT_JOIN:
//                return NSLocalizedString(@"err_def_guild_group_cannot_join", nil);
//            case ERR_GROUP_APPLY_EXIST:
//                return NSLocalizedString(@"err_def_guild_group_apply_exist", nil);
//            case ERR_GROUP_APPLY_NOT_EXIST:
//                return NSLocalizedString(@"err_def_guild_group_apply_not_exist", nil);
//            case ERR_GROUP_APPLY_HAVE_REVIEWED:
//                return NSLocalizedString(@"err_def_guild_group_apply_have_reviewed", nil);
//            case ERR_GROUP_USER_HAVE_BEEN_OWNER:
//                return NSLocalizedString(@"err_def_guild_group_user_is_owner", nil);
//            case ERR_GUILD_ADD_GAME_EXIST:
//                return NSLocalizedString(@"err_def_guild_add_game_exist", nil);
//            case ERR_GROUP_DELETE_MEMBER_SELF:
//                return NSLocalizedString(@"err_def_guild_group_delete_member_self", nil);
//            case ERR_GUILD_DELETE_MEMBER_SELF:
//                return NSLocalizedString(@"err_def_guild_delete_member_self", nil);
//            case ERR_GROUP_MUTE_MEMBER_SELF:
//                return NSLocalizedString(@"err_def_guild_group_mute_member_self", nil);
//            case ERR_GROUP_UNMUTE_MEMBER_SELF:
//                return NSLocalizedString(@"err_def_guild_group_unmute_member_self", nil);
//            case ERR_GROUP_CANNOT_EXIT_GUILD_MAIN_GROUP:
//                return NSLocalizedString(@"err_def_guild_cannot_exist_guild_main_group", nil);
//            case ERR_GROUP_PARAM_ERR:
//                return NSLocalizedString(@"err_def_guild_group_param_err", nil);
//            case ERR_GUILD_GAME_NOT_EXIST:
//                return NSLocalizedString(@"err_def_game_not_exist", nil);
//            case ERR_GUILD_NOTICE_DUPLICATE_DELETE:
//                return NSLocalizedString(@"err_def_guild_notice_duplicate_delete", nil);
//            case ERR_GROUP_USER_NOT_OWNER:
//                return NSLocalizedString(@"err_def_guild_group_user_not_owner", nil);
//            case ERR_GUILD_CANT_DISMISS_MEMBER_TO_MUCH:
//                return NSLocalizedString(@"err_def_guild_cannot_dismiss_member_too_many", nil);
//            case ERR_GUILD_ALREADY_JOIN:
//                return NSLocalizedString(@"err_def_guild_already_join", nil);
//            case ERR_GUILD_SET_GAME_URL_INVALID:
//                return NSLocalizedString(@"err_def_guild_set_game_url_invalid", nil);
//            case ERR_GUILD_ID_NOT_MATCH:
//                return NSLocalizedString(@"err_def_guild_id_not_match", nil);
//            case ERR_GUILD_SET_GAME_URL_CANT_REACH:
//                return NSLocalizedString(@"err_def_guild_set_game_url_cannot_reach", nil);
//            case ERR_GUILD_SET_GAME_URL_NOT_APK:
//                return NSLocalizedString(@"err_def_guild_set_game_url_not_apk", nil);
//            case ERR_GUILD_APPLY_USER_JOIN_OTHER_GUILD:
//                return NSLocalizedString(@"err_def_guild_apply_user_join_other_guild", nil);
//            case ERR_GUILD_MAIN_GROUP_NO_OWNER:
//                return NSLocalizedString(@"err_def_guild_main_group_no_owner", nil);
//            case ERR_GAME_NOT_EXIST:
//                return NSLocalizedString(@"err_def_game_not_exist", nil);
//            case ERR_GAME_FUZZY_MATCH_NOT_READY:
//                return NSLocalizedString(@"err_def_game_fuzzy_match_not_ready", nil);
//            case ERR_AUTH_AUTO_LOGIN_ALREADY_ONLINE:
//                return NSLocalizedString(@"err_def_auth_auto_login_already_online", nil);
//            case ERR_AUTH_AUTO_LOGIN_FAILED:
//                return NSLocalizedString(@"err_def_auth_auto_login_failed", nil);
//            case ERR_ALBUM_NOT_EXIST:
//                return NSLocalizedString(@"err_def_album_not_exist", nil);
//            case ERR_PHOTO_NOT_EXIST:
//                return NSLocalizedString(@"err_def_album_photo_not_exist", nil);
//            case ERR_ALBUM_DEFAULT_ALBUM_CANT_DELETE:
//                return NSLocalizedString(@"err_def_album_default_album_cannot_delete", nil);
//            case ERR_NO_PERMISSION_DELETE_ALBUM:
//                return NSLocalizedString(@"err_def_album_no_permission_delete_album", nil);
//            case ERR_NO_PERMISSION_DELETE_PHOTO:
//                return NSLocalizedString(@"err_def_album_no_permission_delete_photo", nil);
//            case ERR_GIFTPKG_GUILD_PKG_NOT_ENOUGH:
//                return NSLocalizedString(@"err_def_giftpkg_guild_pkg_not_enough", nil);
//            case ERR_GIFTPKG_PKG_NOT_FOUND:
//                return NSLocalizedString(@"err_def_giftpkg_pkg_not_found", nil);
//            case ERR_GIFTPKG_ALREADY_APPLYING:
//                return NSLocalizedString(@"err_def_giftpkg_already_applying", nil);
//            case ERR_GIFTPKG_APPLYID_DONE_OR_NOT_EXIST:
//                return NSLocalizedString(@"err_def_giftpkg_apply_done_or_not_exist", nil);
//            case ERR_GIFTPKG_APPLYID_NOT_EXIST:
//                return NSLocalizedString(@"err_def_giftpkg_apply_not_exist", nil);
//            case ERR_GIFTPKG_APPLYID_ALREADY_DONE:
//                return NSLocalizedString(@"err_def_giftpkg_apply_already_done", nil);
//            case ERR_GIFTPKG_PKG_NOT_ENOUGH:
//                return NSLocalizedString(@"err_def_giftpkg_pkg_not_enough", nil);
//            case ERR_GIFTPKG_APPLY_NO_PERMISSION:
//                return NSLocalizedString(@"err_def_giftpkg_apply_no_permission", nil);
//            case ERR_GIFTPKG_USER_HAD_FETED_THIS_PKG:
//                return NSLocalizedString(@"err_def_giftpkg_user_taken_pkg", nil);
//            case ERR_GIFTPKG_TAOHAO_NO_USABLE_ID:
//                return NSLocalizedString(@"err_def_giftpkg_taohao_no_usable_id", nil);
//            case ERR_GIFTPKG_RED_PKG_EMPTY:
//                return NSLocalizedString(@"err_def_giftpkg_red_pkg_empty", nil);
//            case ERR_GIFTPKG_APPLY_HAS_NO_THIS_GAME:
//                return NSLocalizedString(@"err_def_giftpkg_apply_has_no_this_game", nil);
//            case ERR_GIFTPKG_NOT_FOUND_RED_PKG:
//                return NSLocalizedString(@"err_def_giftpkg_red_pkg_not_found", nil);
//            case ERR_GIFTPKG_RED_PKG_TARGET_ERR:
//                return NSLocalizedString(@"err_def_giftpkg_red_pkg_target_err", nil);
//            case ERR_GIFTPKG_RED_PKG_GUILD_ERR:
//                return NSLocalizedString(@"err_def_giftpkg_red_pkg_guild_err", nil);
//            case ERR_GIFTPKG_ALREADY_FETCH_REDPKG:
//                return NSLocalizedString(@"err_def_giftpkg_already_taken_red_pkg", nil);
//            case ERR_GIFTPKG_NOT_GUILD_OWNER:
//                return NSLocalizedString(@"err_def_giftpkg_not_guild_owner", nil);
//            case ERR_GIFTPKG_PKG_NOT_USED:
//                return NSLocalizedString(@"err_def_giftpkg_pkg_not_used", nil);
//            case ERR_GAME_CIRCLE_SEND_TOPIC_COMPRESS_IMG_FAILED:
//                return NSLocalizedString(@"err_def_game_circle_send_topic_compress_img_failed", nil);
//            case ERR_GAME_CIRCLE_SEND_TOPIC_UPLOAD_IMG_FAILED:
//                return NSLocalizedString(@"err_def_game_circle_send_topic_upload_img_failed", nil);
//            case ERR_IMAGE_DECODE_ERROR:
//                return NSLocalizedString(@"err_def_image_decode_error", nil);
//            case ERR_CIRCLE_TOPIC_TITLE_SENSITIVE:
//                return NSLocalizedString(@"err_def_circle_topic_title_sensitive", nil);
//            case ERR_CIRCLE_TOPIC_CONTENT_SENSITIVE:
//                return NSLocalizedString(@"err_def_circle_topic_content_sensitive", nil);
//            case ERR_CIRCLE_COMMENT_SENSITIVE:
//                return NSLocalizedString(@"err_def_circle_comment_sensitive", nil);
//
//            case ERR_CIRCLE_POST_TOPIC_COOLINGDOWN:
//                return NSLocalizedString(@"err_def_circle_post_topic_coolingdown", nil);
//            case ERR_CIRCLE_POST_COMMENT_COOLINGDOWN:
//                return NSLocalizedString(@"err_def_circle_post_comment_coolingdown", nil);
//            case ERR_CIRCLE_POST_SIMILAR_TOPIC:
//                return NSLocalizedString(@"err_def_circle_post_similar_topic", nil);
//            case ERR_DEVICE_NOT_SUPPORT_TEAM_VOICE:
//                return @"你的手机机型暂不支持开黑语音功能，我们正在努力优化中，等着我们的好消息吧～";
//            case ERR_ACCOUNT_PHONE_BINDED_TO_ANOTHER:
//                return NSLocalizedString(@"err_def_account_phone_binded_to_another", nil);
//
//            case ERR_SEND_MSG_FRIEND_VERIFY_FAILED:
//            case ERR_SEND_MSG_WRITE_MSG_FAILED:
//            case ERR_SEND_MSG_GET_NICK_FAILED:
//            case ERR_SEND_MSG_GET_USERACCOUNT_FAILED:
//            case ERR_FRIEND_SYSTEM_ERR:
//            case ERR_ACCOUNT_SYSTEM_ERR:
//            case ERR_SEQ_GEN_SYSTEM_ERR:
//            case ERR_HEAD_IMAGE_SYSTEM_ERR:
//            case ERR_CHECK_FRIEND_SYSTEM_ERR:
//            case ERR_TIMELINE_SVR_SYSTEM_ERR:
//            case ERR_ATTACHMENT_SVR_SYSTEM_ERR:
//            case ERR_GUILD_TIMELINE_SVR_SYSTEM_ERR:
//            case ERR_SEARCH_SVR_SYSTEM_ERR:
//            case ERR_GUILD_SVR_SYSTEM_ERR:
//            case ERR_GAME_SVR_SYSTEM_ERR:
//            case ERR_ALBUM_SVR_SYSTEM_ERR:
//            case ERR_GIFTPKG_SVR_SYSTEM_ERR:
//
//                return NSLocalizedString(@"err_def_sys", nil);
//            default:
//                return NSLocalizedString(@"err_def_unknown_error", nil);
//
//        }
//
//
//    } else if ([error.domain isEqualToString:HCErrorDomain]) {
//        switch (error.code) {
//            case HC_RESULTTYPE_CHANNEL_BAN_JOIN:
//                return NSLocalizedString(@"err_def_hc_join_channel_failed_banned", nil);
//                break;
//
//            default:
//                return NSLocalizedString(@"err_def_unknown_error", nil);
//                break;
//        }
//
//    } else {
//        return NSLocalizedString(@"err_def_unknown_error", nil);
//    }
    return @"网络错误";
}

@end
