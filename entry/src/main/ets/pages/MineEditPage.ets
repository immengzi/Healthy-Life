/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { router } from '@kit.ArkUI';

import { CommonConstants } from '../common/constants/UserConstants';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import Logger from '../common/utils/Logger';
import { DateModel } from '../viewmodel/DateModel';
import { getRealTimeDate } from '../viewmodel/GetDate';


@Entry
@Component
struct Index {
  @State selectGenderIndex: number = 0
  private provideGender: string[] = ['保密', '男', '女'];
  @State selectGender: string = this.provideGender[this.selectGenderIndex]
  @State currentMonth: number = 1;
  @State currentDay: number = 1;
  @State currentYear: number = 1;
  @StorageLink('selectedDate') dateModel: DateModel = new DateModel(0, 0, 0, 0);
  private selectedDate: Date = new Date()

  onCancel() {
  }

  aboutToAppear(): void {
    this.dateModel = getRealTimeDate();
    this.currentMonth = this.dateModel.month;
    this.currentDay = this.dateModel.day;
    this.currentYear = this.dateModel.year;
  }

  @Builder
  Options(name: Resource, url: string, value: string = "???") {
    Row() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text(name)
            .fontSize($r('app.float.card_padding'))
            .fontWeight(FontWeight.Medium)

          if (url == '性别') {
            Text(this.selectGender)
              .fontSize($r('app.float.card_padding'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.no_data_background'))
              .textAlign(TextAlign.End)
          } else if (url == '生日') {
            Text(`${this.dateModel.year}年${this.dateModel.month}月${this.dateModel.day}日`)
              .fontSize($r('app.float.card_padding'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.no_data_background'))
              .textAlign(TextAlign.End)
          } else {
            Text(value)
              .fontSize($r('app.float.card_padding'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.no_data_background'))
              .textAlign(TextAlign.End)
          }


          Image($r('app.media.ic_right_grey'))
            .objectFit(ImageFit.Contain)
            .height($r('app.float.default_12'))
            .width($r('app.float.default_12'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({
        left: $r('app.float.default_4'),
        right: $r('app.float.default_12')
      })

      Blank()
      Row()
        .width(Const.THOUSANDTH_1000)
        .height(Const.THOUSANDTH_1000)
        .border({
          width: { top: $r('app.float.border'), right: $r('app.float.border') },
          color: $r('app.color.white')
        })
        .rotate({ angle: CommonConstants.ANGLE })
    }
    .borderRadius($r('app.float.text_size_headline'))
    .shadow({
      radius: $r('app.float.shadow_radius'),
      color: $r('app.color.white')
    })
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height($r('app.float.row_height'))
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('app.float.column_padding'),
      top: $r('app.float.column_padding'),
      bottom: $r('app.float.column_padding')
    })
    .border({
      width: { bottom: $r('app.float.default_1') },
      color: $r('app.color.borderColor')
    })
    .backgroundColor(Color.White)
    .onClick(() => {
      if (url == '性别') {
        TextPickerDialog.show({
          range: this.provideGender,
          selected: this.selectGenderIndex,
          backgroundColor: $r('app.color.white'),
          onAccept: (value: TextPickerResult) => {
            this.selectGenderIndex = value.index as number;
            this.selectGender = value.value as string;
            Logger.debug('MineEditPage', '编辑性别');
          },
          canLoop: false
        })
        return
      }
      if (url == '生日') {
        // this.dialogController.open();
        CalendarPickerDialog.show({
          selected: this.selectedDate,
          onAccept: (value) => {
            console.info("calendar onAccept:" + JSON.stringify(value))
            this.dateModel.month = value.getMonth()
            this.dateModel.year = value.getFullYear()
            this.dateModel.day = value.getDate()
          },
        })
        return
      }
      router.pushUrl({
        url
      })
    })
  }

  build() {
    Row() {
      Navigation() {
        Column() {
          this.Options($r('app.string.user_name'), 'pages/MineEditNamePage')
          this.Options($r('app.string.gender'), '性别', this.selectGender)
          this.Options($r('app.string.birth_data'), '生日')
          this.Options($r('app.string.height'), 'pages/Toast')
          this.Options($r('app.string.weight'), 'pages/Privacy')
        }
      }
      .size({ width: Const.THOUSANDTH_1000, height: Const.THOUSANDTH_1000 })
      .title($r('app.string.base_personal_data'))
      .titleMode(NavigationTitleMode.Mini)
    }
    .height(Const.THOUSANDTH_1000)
    .backgroundColor($r('app.color.primaryBgColor'))
  }
}