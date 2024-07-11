/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Logger from '../common/utils/Logger';
// PictureSaving.ets
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import UserInfoData from '../viewmodel/UserInfoData';
import UserInfoApi from '../common/database/tables/UserInfoApi';
import { buffer, util } from '@kit.ArkTS';

// 定义一个URI数组，用于接收PhotoViewPicker返回的用于选择图像的URI。
let uris: Array<string> = [];

// 调用PhotoViewPicker.select选择图片。
export async function photoPickerGetUri(): Promise<string> {
  try {
    let PhotoSelectOptions = new picker.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 1;
    let photoPicker = new picker.PhotoViewPicker();
    await photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: picker.PhotoSelectResult) => {
      Logger.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
      uris = PhotoSelectResult.photoUris;
    }).catch((err: BusinessError) => {
      Logger.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  } catch (error) {
    let err = error as BusinessError;
    Logger.error('PhotoViewPicker failed with err: ' + err.message);
  }
  return uris[0].toString();
}

@Component
export struct UserBaseInfo {
  @Prop nickname: string = '';
  @Prop signature: string = '';
  @Prop icon: string = ''
  @State userInfo: UserInfoData[] = [];
  private UserInfoTable = new UserInfoApi(() => {
  });

  aboutToAppear(): void {
    // 查找用户信息
    this.UserInfoTable.getRdbStore(() => { // 获取数据库
      this.UserInfoTable.query(1, (result: UserInfoData[]) => { // 查询数据库中的用户
        this.userInfo.push(result[0]);
        // this.icon = this.userInfo[0].icon
      }, false);
    });
  }

  build() {
    Column() {
      // userIcon
      Column() {
        if (this.icon != '') {
          Image(this.icon)
            .height($r('app.float.default_66'))
            .width($r('app.float.default_66'))
            .margin({ top: $r('app.float.default_71') })
            .borderRadius($r('app.float.default_40'))
            .onComplete(msg => {
              if (msg) {
                Logger.debug('UserBaseInfo', JSON.stringify(msg))
              }
            })// 图片获取失败，打印结果
            .onError(error => {
              Logger.debug('UserBaseInfo', `load image fail ${this.icon}`)
              Logger.debug('UserBaseInfo', JSON.stringify(error))
            })
        } else {
          Image($r('app.media.ic_user'))
            .objectFit(ImageFit.Contain)
            .height($r('app.float.default_66'))
            .width($r('app.float.default_66'))
            .margin({ top: $r('app.float.default_71') })
        }
      }.onClick(async () => {
        Logger.debug('UserBaseInfo', '打开相册');
        await photoPickerGetUri().then(value => {
          this.icon = value;
          Logger.debug('UserBaseInfo', this.icon);
        });
        // 保存
        this.UserInfoTable.getRdbStore(() => { // 获取数据库
          this.userInfo[0].icon = this.icon
          Logger.info('UserBaseInfo', `编辑头像 ${this.userInfo[0].icon}`);
          this.UserInfoTable.updateData(this.userInfo[0], () => {
          });
        });
      })

      Column() {
        Text('LV.7')
          .fontSize($r('app.float.default_12'))
          .fontWeight(FontWeight.Bolder)
          .fontColor($r('app.color.leveColor'))
      }
      .width($r('app.float.default_44'))
      .height($r('app.float.default_16'))
      .margin({ top: $r('app.float.default_n8') })
      .border({ radius: $r('app.float.default_5') })
      .backgroundColor($r('app.color.leveBgColor'))
      .justifyContent(FlexAlign.Center)

      // nickname
      Text(`${this.nickname}`,)
        .fontSize($r('app.float.default_20'))
        .fontFamily($r('app.string.Helvetica'))
        .margin({ bottom: $r('app.float.default_6') })
        .fontWeight(FontWeight.Normal)
        .fontColor($r('app.color.black'))

      // signature
      Text(this.signature).fontSize($r('app.float.default_16')).fontWeight(FontWeight.Normal)
        .fontFamily($r('app.string.PingFangSC_Regular'))
        .fontColor($r('app.color.signatureColor'))
    }
  }
}