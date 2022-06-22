--[[ Translator: meatgaga#9470 ]] --
local L = LibStub("AceLocale-3.0"):NewLocale("Skada", "zhCN")
if not L then return end

L["A damage meter."] = "伤害统计器"
L["Memory usage is high. You may want to reset Skada, and enable one of the automatic reset options."] = "内存使用率很高。你可能需要重置Skada，并启用其中一个自动重置选项。"
L["Skada is out of date. You can download the newest version from \124cffffbb00%s\124r"] = "Skada已过期。你可以在\124cffffbb00%s\124r下载到最新的版本。"
L["Skada: Modes"] = "Skada：模式"
L["Skada: Fights"] = "Skada：战斗"
L["Data Collection"] = "数据收集"
L["ENABLED"] = "已启用"
L["DISABLED"] = "已禁用"
L["Enable All"] = "全部启用"
L["Disable All"] = "禁用所有"
L["Stopping for wipe."] = "因擦拭而停止。"
L["Usage:"] = "利用："
-- profiles
L["Profiles"] = "配置文件"
L["Profile Import/Export"] = "配置文件导入/导出"
L["Import Profile"] = "导入配置文件"
L["Export Profile"] = "导出配置文件"
L["Paste here a profile in text format."] = "在此处粘贴文本格式的配置文件。"
L["Press CTRL-V to paste a Skada configuration text."] = "按 CTRL-V 粘贴 Skada 配置文本。"
L["This is your current profile in text format."] = "这是您当前的文本格式的个人资料。"
L["Press CTRL-C to copy the configuration to your clipboard."] = "按 CTRL-C 将配置复制到剪贴板。"
L["Network Sharing"] = "網絡共享"
L["Player Name"] = "选手姓名"
L["Send Profile"] = "发送个人资料"
L["Accept profiles from other players."] = "接受来自其他玩家的个人资料。"
L["opt_profile_received"] = "%s 發送一份設定檔給你，你是否想啟用他?"
L["Progress"] = "进展"
L["Data Size: \124cffffffff%.1f\124rKB"] = "资料量：\124cffffffff%.1f\124rKB"
L["Transmision Progress: %02.f%%"] = "传输进度：%d%%"
L["Transmission Completed"] = "传输完成"
-- common lines
L["Options"] = "选项"
L["Options for %s."] = "%s状态的选项。"
L["General"] = "常规"
L["General options for %s."] = "%s 的常规选项。"
L["Text"] = "文字"
L["Text options for %s."] = "%s 的文本选项。"
L["Format"] = "格式"
L["Format options for %s."] = "%s 的格式选项。"
L["Appearance"] = "外貌"
L["Appearance options for %s."] = "%s 的外观选项。"
L["Advanced"] = "高级"
L["Advanced options for %s."] = "%s 的高级选项。"
L["Position"] = "位置设置"
L["Position settings for %s."] = "%s 的位置选项。"
L["Width"] = "宽度"
L["The width of %s."] = "%s 的宽度。"
L["Height"] = "高度"
L["The height of %s."] = "%s 的高度。"
L["Verbose Mode"] = "冗长模式"
L["Enable verbose mode for %s."] = "为 %s 启用详细模式。"
L["More Details"] = "更多细节"
L["Active Time"] = "活跃时间"
L["Segment Time"] = "分段时间"
L["Click for \124cff00ff00%s\124r"] = "点击后为 \124cff00ff00%s\124r"
L["Shift-Click for \124cff00ff00%s\124r"] = "Shift+点击后为 \124cff00ff00%s\124r"
L["Control-Click for \124cff00ff00%s\124r"] = "Ctrl+点击后为 \124cff00ff00%s\124r"
L["Alt-Click for \124cff00ff00%s\124r"] = "Alt+点击后为 \124cff00ff00%s\124r"
L["Toggle Class Filter"] = "按类筛选"
L["Average"] = "平均"
L["Casts"] = "施放"
L["Count"] = "计数"
L["Refresh"] = "刷新"
L["Percent"] = "百分比"
L["sPercent"] = "百分比 (子模块)"
L["General Options"] = "常规选项"
L["HoT"] = " (治疗/跳)"
L["DoT"] = " (伤害/跳)"
L["Hits"] = "命中"
L["Normal Hits"] = "普通攻击"
L["Critical"] = "暴击"
L["Critical Hits"] = "暴击一击"
L["Crushing"] = "碾压"
L["Glancing"] = "穿刺"
L["ABSORB"] = "吸收"
L["BLOCK"] = "格挡"
L["DEFLECT"] = "偏斜"
L["DODGE"] = "躲闪"
L["EVADE"] = "闪避"
L["IMMUNE"] = "免疫"
L["MISS"] = "未命中"
L["PARRY"] = "招架"
L["REFLECT"] = "反射"
L["RESIST"] = "抵制"
L["Only for bosses."] = "只针对老板。"
L["Enable this only against bosses."] = "只对老板启用此。"
-- windows section:
L["Window"] = "窗口"
L["Windows"] = "窗口"
L["Create Window"] = "创建窗口"
L["Window Name"] = "窗口名称"
L["Enter the name for the new window."] = "输入新窗口的名字。"
L["Delete Window"] = "删除窗口"
L["Choose the window to be deleted."] = "选择要删除的窗口。"
L["Are you sure you want to delete this window?"] = "确定要删除此窗口？"
L["Rename Window"] = "重命名窗口"
L["Enter the name for the window."] = "输入窗口的名字。"
L["Test Mode"] = "测试模式"
L["Creates fake data to help you configure your windows."] = "创建虚假数据以帮助您配置窗口。"
L["Child Window"] = "子窗口"
L["A child window will replicate the parent window actions."] = "子窗口将复制父窗口的动作。"
-- L["Child Window Mode"] = ""
L["Lock Window"] = "锁定窗口"
L["Locks the bar window in place."] = "在当前位置锁定统计条窗口。"
L["Hide Window"] = "隐藏窗口"
L["Hides the window."] = "隐藏此窗口。"
L["Sticky Window"] = "粘窗"
L["Allows the window to stick to other Skada windows."] = "允许窗口捕捉到其他Skada窗口。"
L["Snap to best fit"] = "自动适应大小"
L["Snaps the window size to best fit when resizing."] = "在调整大小时自动根据最适合的大小依附窗口。"
L["Disable Resize Buttons"] = "禁用缩放按钮"
L["Resize and lock/unlock buttons won't show up when you hover over the window."] = "当您将鼠标悬停在窗口上时，不会出现缩放和锁定/解锁按钮。"
L["Disable stretch button"] = "禁用拉伸按钮"
L["Stretch button won't show up when you hover over the window."] = "当您将鼠标悬停在窗口上时，不会显示拉伸按钮。"
L["Reverse window stretch"] = "向下拉伸窗口"
L["opt_botstretch_desc"] = "将拉伸按钮放置在窗口底部，并使后者向下拉伸。"
L["Display System"] = "显示系统"
L["Choose the system to be used for displaying data in this window."] = "选择在窗口中显示数据的系统。"
L["Copy Settings"] = "复制设定"
L["Choose the window from which you want to copy the settings."] = "选择要从中复制设置的窗口。"
-- bars
L["Bars"] = "统计条"
L["Left Text"] = "左文字"
L["Right Text"] = "右文字"
L["Font"] = "字体"
L["The font used by %s."] = "%s 使用的字体。"
L["Font Size"] = "字体大小"
L["The font size of %s."] = "%s 的字体大小。"
L["Font Outline"] = "字體輪廓"
L["Sets the font outline."] = "设置字体轮廓。"
L["Outline"] = "轮廓"
L["Thick outline"] = "粗轮廓"
L["Monochrome"] = "单色"
L["Outlined monochrome"] = "轮廓单色"
L["Bar Texture"] = "统计条材质"
L["The texture used by all bars."] = "全部统计条所使用的材质。"
L["Spacing"] = "间距"
L["Distance between %s."] = "%s 之间的距离。"
L["Displacement"] = "位移"
L["The distance between the edge of the window and the first bar."] = "窗口边缘与第一个栏之间的距离。"
L["Bar Orientation"] = "统计条方向"
L["The direction the bars are drawn in."] = "统计条的绘制方向。"
L["Left to right"] = "从左到右"
L["Right to left"] = "从右到左"
L["Reverse bar growth"] = "反转增长方向"
L["Bars will grow up instead of down."] = "统计条向上增长。"
L["Disable bar highlight"] = "禁用计量条高亮"
L["Hovering a bar won't make it brighter."] = "鼠标悬浮在计量条上不会高亮显示。"
L["Bar Color"] = "统计条颜色"
L["Choose the default color of the bars."] = "选择统计条的默认颜色。"
L["Background Color"] = "背景颜色"
L["Choose the background color of the bars."] = "选择统计条的背景颜色。"
L["Spell school colors"] = "法术派系颜色"
L["Use spell school colors where applicable."] = "在适用处使用法术派系颜色。"
L["When possible, bars will be colored according to player class."] = "可用时，统计条按玩家职业着色。"
L["When possible, bar text will be colored according to player class."] = "可用时，统计条文字按玩家职业着色。"
L["Class Icons"] = "职业图标"
L["Use class icons where applicable."] = "在适用处使用职业图标。"
L["Spec Icons"] = "天赋图标"
L["Use specialization icons where applicable."] = "在适用处使用天赋图标。"
L["Role Icons"] = "职责图标"
L["Use role icons where applicable."] = "在适用处使用职责图标。"
L["Show Spark Effect"] = "显示光斑效果"
L["Click Through"] = "点击穿透"
L["Disables mouse clicks on bars."] = "在统计条上禁用鼠标点击。"
L["Smooth Bars"] = "平滑化"
L["Animate bar changes smoothly rather than immediately."] = "以动画平滑显示统计条变化。"
-- title bar
L["Title Bar"] = "标题栏"
L["Enables the title bar."] = "启用标题栏。"
L["Include set"] = "包括集合"
L["Include set name in title bar"] = "在标题栏中包括集合名称。"
L["Encounter Timer"] = "战斗计时器"
L["When enabled, a stopwatch is shown on the left side of the text."] = "启用后，在文字左侧显示一个秒表。"
L["Mode Icon"] = "模式图标"
L["Shows mode's icon in the title bar."] = "在标题栏中显示模式的图标。"
L["The texture used as the background of the title."] = "用于标题背景的材质。"
L["The background color of the title."] = "标题的背景颜色。"
L["Border texture"] = "边框材质"
L["The texture used for the borders."] = "用于边框的材质。"
L["Border Color"] = "边框颜色"
L["The color used for the border."] = "边框所使用的颜色。"
L["Buttons"] = "按钮"
L["Auto Hide Buttons"] = "自动隐藏菜单"
L["Show window buttons only if the cursor is over the title bar."] = "仅当光标在标题栏上方时才显示窗口按钮。"
L["Buttons Style"] = "按钮样式"
-- general window
L["Background"] = "背景"
L["Background Texture"] = "背景材质"
L["The texture used as the background."] = "用于背景的材质。"
L["Tile"] = "平铺"
L["Tile the background texture."] = "平铺背景材质。"
L["Tile Size"] = "平铺尺寸"
L["The size of the texture pattern."] = "材质图案的尺寸。"
L["The color of the background."] = "背景的颜色。"
L["Border"] = "边框"
L["Border Thickness"] = "边框粗细"
L["The thickness of the borders."] = "边框的粗细。"
L["Border Insets"] = "边界距离"
L["The distance between the window and its border."] = "窗口和它的边界之间的距离。"
L["Scale"] = "缩放"
L["Sets the scale of the window."] = "设定窗口的缩放比例。"
L["Strata"] = "层级"
L["This determines what other frames will be in front of the frame."] = "此项指定其他哪些框架将位于此框架的前面。"
L["Clamped To Screen"] = "限制在屏幕內"
L["Toggle whether to permit movement out of screen."] = "打开/关闭是否允许把框架移到超出屏幕的位置。"
L["X Offset"] = "X 偏移"
L["Y Offset"] = "Y 偏移"
-- switching
L["Mode Switching"] = "模式切换"
L["Combat Mode"] = "战斗模式"
L["opt_combatmode_desc"] = "进入战斗时自动切换到\124cffffbb00当前\124r集合和此模式。"
L["Wipe Mode"] = "团灭模式"
L["opt_wipemode_desc"] = "团灭后自动切换到\124cffffbb00当前\124r集合和此模式。"
L["Return after combat"] = "战斗后返回"
L["Return to the previous set and mode after combat ends."] = "战斗结束后返回原先的集合和模式。"
L["Auto switch to current"] = "自动切换到当前"
L["opt_autocurrent_desc"] = "每当战斗开始这个窗口自动切换到\124cffffbb00当前\124r片段。"
L["Auto Hide"] = "自动隐藏"
L["While in combat"] = "战斗中"
L["While out of combat"] = "脱离战斗"
L["While not in a group"] = "当退出队伍"
L["While inside an instance"] = "当在战斗中"
L["While not inside an instance"] = "当不在战斗中"
L["In Battlegrounds"] = "在战场"
L["Inline Bar Display"] = "直排统计条显示"
L["mod_inline_desc"] = "直排显示是一种水平窗口样式。"
L["Font Color"] = "字体颜色"
L["Font Color.\nClick \"Class Colors\" to begin."] = "字体的颜色。\n点击“班级颜色”开始。"
L["opt_barwidth_desc"] = "统计条的宽度。此项仅在“固定统计条宽度”选项启用后生效。"
L["Fixed bar width"] = "固定统计条宽度"
L["opt_fixedbarwidth_desc"] = "勾选后，统计条的宽度固定。否则，统计条宽度取决于文字长度。"
L["Class Colors"] = "班级颜色"
L["Use class colors for %s."] = "对 %s 使用类颜色。"
L["opt_isusingclasscolors_desc"] = "职业颜色：\n\124cFFF58CBAKader\124r - 5.71M (21.7K)\n\n普通颜色：\nKader - 5.71M (21.7K)"
L["Put values on new line."] = "提行显示数值"
L["opt_isonnewline_desc"] = "提行：\nKader\n5.71M (21.7K)\n\n单行：\nKader - 5.71M (21.7K)"
L["Use ElvUI skin if avaliable."] = "可用时使用ElvUI皮肤。"
L["opt_isusingelvuiskin_desc"] = "勾选此项以使用ElvUI皮肤。\n默认：勾选"
L["Use solid background."] = "使用纯色背景。"
L["Un-check this for an opaque background."] = "不勾选此项将使用不透明背景。"
L["Data Text"] = "数据文字"
L["mod_broker_desc"] = "数据文本作为一个 LDB 数据聚合。可以集成在任何 LDB 显示，如 Titan Panel 或 ChocolateBar。它也有一个可选的内部框架。"
L["Use frame"] = "使用窗口"
L["opt_useframe_desc"] = "显示一个独立的框架。 如果您使用的是 LDB 显示提供程序，例如 Titan Panel 或 ChocolateBar，则不需要。"
L["Text Color"] = "文字颜色"
L["Choose the default color."] = "选择默认颜色。"
L["Hint: Left-Click to set active mode."] = "提示：左键点击：设定活跃模式。"
L["Right-Click to set active set."] = "右键点击：设定活跃集合。"
L["Shift+Left-Click to open menu."] = "Shift+左键点击：打开菜单。"
-- data resets
L["Data Resets"] = "数据重置"
L["Reset on entering instance"] = "进本重置"
L["Controls if data is reset when you enter an instance."] = "控制是否在进入副本时重置数据。"
L["Reset on joining a group"] = "入队重置"
L["Controls if data is reset when you join a group."] = "控制是否在加入队伍时重置数据。"
L["Reset on leaving a group"] = "离队重置"
L["Controls if data is reset when you leave a group."] = "控制是否在离开队伍时重置数据。"
L["Ask"] = "询问"
L["Do you want to reset Skada?\nHold SHIFT to reset all data."] = "是否要重置数据？\n按住 SHIFT 重置所有。"
L["All data has been reset."] = "全部数据已重置。"
L["There is no data to reset."] = "没有要重置的数据。"
L["Skip reset dialog"] = "跳过重置对话框"
L["opt_skippopup_desc"] = "如果您希望Skada在没有确认对话框的情况下进行重置，请启用此选项。"
L["Are you sure you want to reinstall Skada?"] = "您确定要重新安装 Skada 吗？"
-- general options
L["Show minimap button"] = "显示小地图按钮"
L["Toggles showing the minimap button."] = "开关小地图按钮的显示。"
L["Transliterate"] = "音译"
L["Converts Cyrillic letters into Latin letters."] = "将西里尔字母转换为拉丁字母。"
L["Merge pets"] = "合并宠物"
L["Merges pets with their owners. Changing this only affects new data."] = "宠物数据与其主人合并。此项变更仅对新数据生效。"
L["Show totals"] = "显示总计"
L["Shows a extra row with a summary in certain modes."] = "在某些模式下显示带有摘要的额外行。"
L["Only keep boss fighs"] = "仅保留BOSS战"
L["Boss fights will be kept with this on, and non-boss fights are discarded."] = "启用后将保留BOSS战数据，而非BOSS战数据则将被丢弃。"
L["Always save boss fights"] = "总是保留BOSS战"
L["Boss fights will be kept with this on and will not be affected by Skada reset."] = "启用后BOSS战将被保存，不会受到Skada重置的影响。"
L["Hide when solo"] = "单练时隐藏"
L["Hides Skada's window when not in a party or raid."] = "不在队伍中时隐藏Skada窗口。"
L["Hide in PvP"] = "PvP中隐藏"
L["Hides Skada's window when in Battlegrounds/Arenas."] = "在战场/竞技场中隐藏Skada窗口。"
L["Hide in combat"] = "战斗中隐藏"
L["Hides Skada's window when in combat."] = "在战斗中隐藏Skada窗口。"
L["Show in combat"] = "在战斗中显示"
L["Shows Skada's window when in combat."] = "在战斗中显示Skada窗口。"
L["Disable while hidden"] = "隐藏时禁用"
L["Skada will not collect any data when automatically hidden."] = "自动隐藏时Skada将不收集任何数据。"
L["Sort modes by usage"] = "按用途排序模式"
L["The mode list will be sorted to reflect usage instead of alphabetically."] = "模式列表将进行排序以反映用途，而不是按字母顺序。"
L["Show rank numbers"] = "显示序号"
L["Shows numbers for relative ranks for modes where it is applicable."] = "在适用处根据模式中的相对等级显示数字编号。"
L["Aggressive combat detection"] = "激进式战斗侦测(Recount模式)"
L["opt_tentativecombatstart_desc"] = [[Skada通常使用非常保守（简单）的战斗侦测方案，在团队副本中效果最佳。通过此选项，Skada可尝试模拟其他伤害统计插件。这在五人本中很有效, 但对于BOSS战则毫无意义。]]
L["Autostop"] = "自动停止"
L["opt_autostop_desc"] = "团队成员超过半数阵亡时自动停止当前分段记录。"
L["Always show self"] = "总是显示自己"
L["opt_showself_desc"] = "即使没有足够空行，仍然将玩家显示在最后。"
L["Number format"] = "数字格式"
L["Controls the way large numbers are displayed."] = "控制大数字的显示方式。"
L["Condensed"] = "简短"
L["Detailed"] = "详细"
L["Combined"] = "合计"
L["Comma"] = "逗号"
L["Numeral system"] = "数字显示"
L["Select which numeral system to use."] = "选择数字显示系统。"
L["Auto"] = "自动"
L["Western"] = "西方"
L["East Asia"] = "东亚"
L["Brackets"] = "括号"
L["Choose which type of brackets to use."] = "选择要使用的括号类型。"
L["Separator"] = "分隔符"
L["Choose which character is used to separator values between brackets."] = "选择使用哪个字符来分隔括号之间的值。"
L["Number of decimals"] = "小数位数"
L["Controls the way percentages are displayed."] = "控制百分比的显示方式。"
L["Data Feed"] = "数据反馈"
L["opt_feed_desc"] = "选择显示在DataBroker上的数据反馈。需要一个LDB显示插件，例如Titan Panel泰坦信息条。"
L["Time Measure"] = "时间测量"
L["Activity Time"] = "活跃时间"
L["Effective Time"] = "有效时间"
L["opt_timemesure_desc"] = [=[|cFFFFFF00活跃|r：每个团队成员的计时器将在其活动停止后暂停，并在恢复活跃时再次计时。这是测量DPS和HPS的常用方法。
|cFFFFFF00有效|r：用于排名，此方法使用经历的战斗时间来测量全部团队成员的DPS和HPS。]=]
L["Number set duplicates"] = "数字集重复"
L["Append a count to set names with duplicate mob names."] = "在集合名称中附加一个重复怪物名字的计数。"
L["Set Format"] = "集合格式"
L["Controls the way set names are displayed."] = "控制集合名称的显示方式。"
L["Links in reports"] = "报告中的链接"
L["When possible, use links in the report messages."] = "如果可能，请使用报告消息中的链接。"
L["Segments to keep"] = "数据分段保留"
L["The number of fight segments to keep. Persistent segments are not included in this."] = "需要保留的战斗数据分段数量。不包括连续的分段数据。"
L["Persistent segments"] = "持久段"
L["The number of persistent fight segments to keep."] = "要保留的持久段数。"
L["Memory Check"] = "内存检查"
L["Checks memory usage and warns you if it is greater than or equal to %dmb."] = "检查内存占用，并在高于%dmb时发出警告。"
L["Disable Comms"] = "禁用通信"
L["Minimum segment length"] = "最小分段长度"
L["The minimum length required in seconds for a segment to be saved."] = "保存段所需的最小长度（秒）。"
L["Update frequency"] = "更新频率"
L["How often windows are updated. Shorter for faster updates. Increases CPU usage."] = "窗口的更新频率。数字越小更新越快，但同时CPU占用越高。"
-- columns
L["Columns"] = "列"
-- tooltips
L["Tooltips"] = "提示框"
L["Show Tooltips"] = "显示提示框"
L["Shows tooltips with extra information in some modes."] = "在某些模式下显示包含额外信息的提示框。"
L["Informative Tooltips"] = "信息性提示框"
L["Shows subview summaries in the tooltips."] = "在提示框中显示子视图摘要。"
L["Subview Rows"] = "子视图行"
L["The number of rows from each subview to show when using informative tooltips."] = "使用信息性提示框时每个子视图的显示行数。"
L["Tooltip Position"] = "提示框位置"
L["Position of the tooltips."] = "提示框的位置。"
L["Top Right"] = "右上"
L["Top Left"] = "左上"
L["Bottom Right"] = "右下"
L["Bottom Left"] = "左下"
L["Smart"] = "智能"
L["Follow Cursor"] = "跟随光标"
L["Top"] = "上"
L["Bottom"] = "下"
L["Right"] = "右"
L["Left"] = "左"
-- disabled modules
L["Modules"] = "组件"
L["Disabled Modules"] = "禁用模块"
L["Modules Options"] = "模块选项"
L["Tick the modules you want to disable."] = "勾选要禁用的模块。"
L["This change requires a UI reload. Are you sure?"] = "此更改需要重载界面。确定重载？"
-- themes options
L["Theme"] = "主题"
L["Themes"] = "主题"
L["Apply Theme"] = "应用主题"
L["Theme applied!"] = "主题已应用！"
L["Name of your new theme."] = "新主题的名称。"
L["Save Theme"] = "保存主题"
L["Delete Theme"] = "删除主题"
L["Are you sure you want to delete this theme?"] = "确定要删除此样式吗？"
-- scroll options
L["Scroll"] = "滚动"
L["Wheel Speed"] = "轮速"
L["opt_wheelspeed_desc"] = "更改在窗口上滚动鼠标滚轮时滚动的速度。"
L["Scroll Icon"] = "滚动图标"
L["Scroll mouse button"] = "滚动鼠标按钮"
-- minimap button
L["Skada Summary"] = "Skada概要"
L["\124cff00ff00Left-Click\124r to toggle windows."] = "\124cff00ff00左键\124r：开关窗口"
L["\124cff00ff00Ctrl+Left-Click\124r to show/hide windows."] = "\124cff00ff00Ctrl+左键\124r：显示/隐藏窗口。"
L["\124cff00ff00Shift+Left-Click\124r to reset."] = "\124cff00ff00Shift+左键\124r：重置"
L["\124cff00ff00Right-Click\124r to open menu."] = "\124cff00ff00右键\124r：打开菜单"
-- skada menu
L["Skada Menu"] = "Skada菜单"
L["Select Segment"] = "选择分段"
L["Delete Segment"] = "删除分段"
L["Keep Segment"] = "保留分段"
L["Toggle Windows"] = "开关窗口"
L["Show/Hide Windows"] = "显示/隐藏窗口"
L["Start New Segment"] = "开始新分段"
L["Start New Phase"] = "开始新阶段"
L["Select All"] = "全选"
L["Deselect All"] = "取消全选"
-- window buttons
L["Configure"] = "配置"
L["Open Config"] = "打开配置"
L["btn_config_desc"] = "打开配置窗口。"
L["btn_reset_desc"] = "重置除标记为保留之外的全部数据。"
L["Segment"] = "分段"
L["btn_segment_desc"] = "跳转至一个指定分段。\n\124cff00ff00Shift 点击\124r: \124cffffbb00下一个\124r片段。\n\124cff00ff00Shift 右键单击\124r: \124cffffbb00以前的\124r片段。\n\124cff00ff00中键\124r: \124cffffbb00当前\124r片段。"
L["Mode"] = "模式"
L["Jump to a specific mode."] = "跳转至一个指定模式。"
L["Report"] = "报告"
L["btn_report_desc"] = "打开一个可以通过各种方式向他人报告数据的对话框。\n\124cff00ff00Shift-点击后为\124r: 快速报告."
L["Stop"] = "停止"
L["btn_stop_desc"] = "停止或继续当前分段。在团灭后很有用。可在设置中设为自动停止。"
L["Segment Stopped."] = "段已停止。"
L["Segment Paused."] = "段已暂停。"
L["Segment Resumed."] = "段已恢复。"
L["Quick Access"] = "快速访问"
-- default segments
L["Total"] = "总计"
L["Current"] = "当前战斗"
-- report module and window
L["Skada: %s for %s:"] = "Skada：%s 对于 %s："
L["Self"] = "自己"
L["Whisper Target"] = "密语对象"
L["Line"] = "线路"
L["Lines"] = "线路"
L["There is nothing to report."] = "没有可报告的内容。"
L["No mode or segment selected for report."] = "没有为报告选定模式或分段。"
-- Bar Display Module --
L["Bar Display"] = "条形图显示"
L["mod_bar_desc"] = "条形图显示是被大多数伤害统计插件所采用的普通条形图窗口。可以高度样式化。"
-- Threat Module --
L["Threat"] = "威胁"
L["Threat Warning"] = "威胁警告"
L["Flash Screen"] = "屏幕闪烁"
L["This will cause the screen to flash as a threat warning."] = "以屏幕闪烁作为威胁警告。"
L["Shake Screen"] = "屏幕晃动"
L["This will cause the screen to shake as a threat warning."] = "以屏幕晃动作为威胁警告。"
L["Warning Message"] = "警报消息"
L["Print a message to screen when you accumulate too much threat."] = "当你仇恨过高时在屏幕上显示警报消息。"
L["Play sound"] = "播放音效"
L["This will play a sound as a threat warning."] = "以播放音效作为威胁警告。"
L["Message Output"] = "输出模式"
L["Choose where warning messages should be displayed."] = "选择应在何处显示警告消息。"
L["Chat Frame"] = "聊天框体"
L["Blizzard Error Frame"] = "Blizzard 错误框体"
L["Threat sound"] = "威胁音效"
L["opt_threat_soundfile_desc"] = "当你的威胁比率达到某个点时播放的音效。"
L["Warning Frequency"] = "警告频率"
L["Threat Threshold"] = "威胁比率"
L["opt_threat_threshold_desc"] = "当你的威胁相对于坦克达到此级别时，将显示警告。"
L["Show raw threat"] = "显示原始威胁"
L["opt_threat_rawvalue_desc"] = "显示相对于坦克的原始威胁比率，而不是范围的修改。"
L["Use focus target"] = "使用焦点"
L["opt_threat_focustarget_desc"] = "让 Skada 额外检查您的“焦点”和“焦点目标”位于“目标”和“目标的目标”之前的顺序显示威胁。"
L["Disable while tanking"] = "作为坦克时不警告"
L["opt_threat_notankwarnings_desc"] = "如果在防御姿态、熊形态、正义之怒与冰霜系时、不显示警报。"
L["Ignore Pets"] = "忽略宠物"
L["opt_threat_ignorepets_desc"] = [=[让 Skada 忽略敌对玩家宠物以确定显示哪些单位的威胁。

玩家宠物|cffffff78攻击|r或者|cffffff78防御|r状态保持威胁与正常的怪物相同，正被攻击目标具有最高的威胁。如果宠物指定攻击一个具体目标，宠物仍然保持在威胁列表，但保持在指定的目标定义100%威胁之上。可以玩家宠物嘲讽以攻击你。

然而，玩家宠物在|cffffff78被动|r模式并没有威胁列表，嘲讽依然不起作用。它们只攻击指定的目标和指令时没有仇恨列表。

当玩家宠物处于|cffffff78跟随|r状态时，宠物的威胁列表被消除并立刻停止攻击，虽然它可能会立即重新指定目标位于攻击/防御模式。]=]
L["> Pull Aggro <"] = ">获得仇恨<"
L["Show Pull Aggro Bar"] = "显示获得仇恨计量条"
L["opt_threat_showaggrobar_desc"] = "显示一个数值威胁计量条，以帮助获得仇恨。"
L["Hide empty window"] = "隐藏空窗口"
L["opt_threat_hideempty_desc"] = "没有可显示的内容时完全隐藏窗口。"
L["Test Warnings"] = "测试警报"
L["TPS"] = "TPS"
L["Threat: Personal Threat"] = "威胁：个人威胁"
-- Absorbs & Healing Module --
L["Healing"] = "治疗"
L["Healing Done"] = "造成治疗"
L["Healing Taken"] = "受到治疗"
L["Healed target list"] = "治疗玩家列表"
L["Healing spell list"] = "治疗法术列表"
L["%s's healing"] = "%s的治疗"
L["%s's healed targets"] = "%s治疗的玩家"
L["actor heal spells"] = function(n1, n2) return ((not n2 or n1 == n2) and "%s的治疗法术" or "%s对%s的治疗"):format(n1, n2) end
L["HPS"] = "HPS"
L["sHPS"] = "HPS (子模块)"
L["Healing: Personal HPS"] = "治疗：个人HPS"
L["RHPS"] = "RHPS"
L["Healing: Raid HPS"] = "治疗：团队HPS"
L["Total Healing"] = "总计治疗"
L["Overheal"] = "过量治疗"
L["Overhealing"] = "过量治疗"
L["Overhealed target list"] = "过量治疗玩家列表"
L["Overheal spell list"] = "过量治疗法术列表"
L["%s's overheal targets"] = "%s过量治疗的玩家"
L["actor overheal spells"] = function(n1, n2) return ((not n2 or n1 == n2) and "%s的过量治疗法术" or "%s对%s的过量治疗"):format(n1, n2) end
L["Absorbs"] = "吸收"
L["Absorbed target list"] = "吸收玩家列表"
L["Absorb spell list"] = "吸收法术列表"
L["%s's absorbed targets"] = "%s的吸收玩家"
L["actor absorb spells"] = function(n1, n2) return ((not n2 or n1 == n2) and "%s的吸收法术" or "%s对%s的吸收"):format(n1, n2) end
L["APS"] = "APS"
L["sAPS"] = "APS (子模块)"
L["Absorbs and Healing"] = "吸收和治疗"
L["Absorbs and healing spells"] = "吸收和治疗法术列表"
L["Absorbed and healed targets"] = "吸收和治疗玩家列表"
L["%s's absorbed and healed targets"] = "%s的吸收和治疗玩家"
L["actor absorb and heal spells"] = function(n1, n2) return ((not n2 or n1 == n2) and "%s的吸收和治疗法术" or "%s对%s的吸收和治疗"):format(n1, n2) end
L["Healing source list"] = "治疗玩家列表"
L["%s's received healing"] = "%s受到的治疗"
L["Healing Done By Spell"] = "法术造成的治疗"
L["Healing spell sources"] = "治疗法术的来源"
-- Auras Module --
L["Uptime"] = "持续时间"
L["Buffs and Debuffs"] = "Buff和Debuff"
L["Buffs"] = "Buff"
L["Buff spell list"] = "Buff法术列表"
L["%s's buffs"] = "%s的Buff"
L["Debuffs"] = "Debuff"
L["Debuff spell list"] = "Debuff法术列表"
L["Debuff target list"] = "Debuff目标列表"
L["Debuff source list"] = "Debuff的来源列表"
L["actor debuffs"] = function(n1, n2) return ((not n2 or n1 == n2) and "%s的Debuff" or "%s 对 %s 的减益"):format(n1, n2) end
L["%s's <%s> targets"] = "%s的<%s>目标"
L["%s's <%s> sources"] = "%s的<%s>的来源"
L["Sunder Counter"] = "破甲统计"
L["Sunder target list"] = "破甲目标列表"
L["Sunder source list"] = "破甲的来源列表"
-- CC Tracker Module --
L["Crowd Control"] = "控制"
L["CC Done"] = "成功控制"
L["CC Taken"] = "受到控制"
L["CC Breaks"] = "打破控制"
L["Crowd Control Spells"] = "人群控制法术"
L["Crowd Control Targets"] = "人群控制目标"
L["Crowd Control Sources"] = "人群控制来源"
L["%s's control spells"] = "%s的控制法术"
L["%s's control targets"] = "%s的控制对象"
L["%s's control sources"] = "%s的控制来源"
L["Ignore Main Tanks"] = "忽略主坦克"
L["%s on %s removed by %s"] = "%s位于%s已被%s移除"
L["%s on %s removed by %s's %s"] = "%s位于%s已被%s的%s移除"
-- Damage Module --
-- environmental damage
L["Environment"] = "环境"
-- damage done module
L["Damage"] = "伤害"
L["Damage target list"] = "伤害目标"
L["Damage spell list"] = "伤害法术列表"
L["Damage spell details"] = "伤害法术详情"
L["Damage spell targets"] = "伤害法术目标"
L["Damage Done"] = "造成伤害"
L["actor damage"] = function(n1, n2) return ((not n2 or n1 == n2) and "%s的伤害" or "%s的伤害于%s"):format(n1, n2) end
L["%s's <%s> damage"] = "%s的<%s>伤害"
L["Useful Damage"] = "有用伤害"
L["Useful damage on %s"] = "对于%s有用伤害"
L["Damage Done By Spell"] = "法术造成伤害"
L["%s's sources"] = "%s的来源"
L["DPS"] = "DPS"
L["sDPS"] = "DPS (子模块)"
L["Damage: Personal DPS"] = "伤害：个人DPS"
L["RDPS"] = "RDPS"
L["Damage: Raid DPS"] = "伤害：团队DPS"
L["Absorbed Damage"] = "吸收伤害"
L["Enable this if you want the damage absorbed to be included in the damage done."] = "如果你想包括吸收伤害到造成的伤害启用此。"
-- damage taken module
L["Damage Taken"] = "承受伤害"
L["Damage taken by %s"] = "%s的承受伤害"
L["Damage source list"] = "伤害来源列表"
L["Damage spell sources"] = "伤害法术来源"
L["Damage Taken By Spell"] = "承受法术伤害"
L["%s's targets"] = "%s的目标"
L["DTPS"] = "DTPS"
L["sDTPS"] = "DTPS (子模块)"
-- enemy damage done module
L["Enemies"] = "敌方相关"
L["Enemy Damage Done"] = "敌方造成伤害"
L["Damage done per player"] = "每人造成伤害"
L["Damage from %s"] = "来自于%s的伤害"
-- enemy damage taken module
L["Enemy Damage Taken"] = "敌方承受伤害"
L["%s's damage sources"] = "%s的伤害来源"
L["%s below %s%%"] = "%s - %s%%"
L["%s - %s%% to %s%%"] = "%s - %s%% 到 %s%%"
L["Phase %s"] = "第 %s 阶段"
L["%s - Phase %s"] = "%s - 第 %s 阶段"
L["%s - Phase 1"] = "%s - 第 1 阶段"
L["%s - Phase 2"] = "%s - 第 2 阶段"
L["%s - Phase 3"] = "%s - 第 3 阶段"
L["\124cffffbb00%s\124r - \124cff00ff00Phase %s\124r started."] = "\124cffffbb00%s\124r - \124cff00ff00第 %s\124r 开始。"
L["\124cffffbb00%s\124r - \124cff00ff00Phase %s\124r stopped."] = "\124cffffbb00%s\124r - \124cff00ff00第 %s\124r 停止。"
L["\124cffffbb00%s\124r - \124cff00ff00Phase %s\124r resumed."] = "\124cffffbb00%s\124r - \124cff00ff00第 %s\124r 恢复。"
-- enemy healing done module
L["Enemy Healing Done"] = "敌方的治疗"
-- avoidance and mitigation module
L["Avoidance & Mitigation"] = "规避和缓解"
L["Damage Breakdown"] = "伤害失败"
L["%s's damage breakdown"] = "%s的伤害失败"
-- friendly fire module
L["Friendly Fire"] = "误伤"
-- useful damage targets
L["Important targets"] = "重要目标"
L["Oozes"] = "软泥怪"
L["Princes overkilling"] = "王子过度伤害"
L["Adds"] = "小怪"
L["Halion and Inferno"] = "海里昂和地狱火"
L["Valkyrs overkilling"] = "瓦格里过度伤害"
-- Deaths Module --
L["%s's deaths"] = "%s的死亡"
L["Death log"] = "死亡记录"
L["%s's death log"] = "%s的死亡记录"
L["Player's deaths"] = "玩家的死亡"
L["%s dies"] = "%s死了"
L["Spell details"] = "法术详情"
L["Spell"] = "法术"
L["Amount"] = "数量"
L["Source"] = "来源"
L["Change"] = "改变"
L["Time"] = "时间"
L["Survivability"] = "生存"
L["Events Amount"] = "事件数量"
L["Set the amount of events the death log should record."] = "设置死亡日志应记录的事件数量。"
L["Minimum Healing"] = "最小愈合"
L["Ignore heal events that are below this threshold."] = "忽略低于此阈值的修复事件。"
L["Announce Deaths"] = "宣布死亡"
L["Announces information about the last hit the player took before they died."] = "宣布玩家死前最后一次命中。"
L["Alternative Display"] = "另类显示"
L["If a player dies multiple times, each death will be displayed as a separate bar."] = "如果玩家多次死亡，每次死亡都会显示为单独的条形图。"
-- activity module
L["Activity"] = "活跃"
-- dispels module lines --
L["Dispel spell list"] = "驱散法术列表"
L["Dispelled spell list"] = "已驱散法术列表"
L["Dispelled target list"] = "已驱散目标列表"
L["%s's dispel spells"] = "%s的驱散法术"
L["%s's dispelled spells"] = "%s的已驱散法术"
L["%s's dispelled targets"] = "%s的已驱散目标"
-- failbot module lines --
L["Fails"] = "失误"
L["%s's fails"] = "%s的失误"
L["Player's failed events"] = "玩家的失误事件"
L["Event's failed players"] = "事件的失误玩家"
L["Report Fails"] = "报告故障"
L["Reports the group fails at the end of combat if there are any."] = "战斗结束时报告失败列表。"
L["Ignored Events"] = "忽略的事件"
-- interrupts module lines --
L["Interrupt spells"] = "打断法术"
L["Interrupted spells"] = "已打断法术"
L["Interrupted targets"] = "已打断目标"
L["%s's interrupt spells"] = "%s的打断法术"
L["%s's interrupted spells"] = "%s的已打断法术"
L["%s's interrupted targets"] = "%s的已打断目标"
L["%s interrupted!"] = "%s已打断！"
-- Power gained module --
L["Resources"] = "能量"
L["Power gained: Mana"] = "能量获得：法力值"
L["Power gained: Rage"] = "能量获得：怒气"
L["Power gained: Energy"] = "能量获得：能量"
L["Power gained: Runic Power"] = "能量获得：符文能量"
L["Mana gained spells"] = "法力值获得法术列表"
L["Rage gained spells"] = "怒气获得法术列表"
L["Energy gained spells"] = "能量获得法术列表"
L["Runic Power gained spells"] = "符文能量获得法术列表"
L["%s's gained %s"] = "%s的获得%s"
-- Parry module lines --
L["Parry-Haste"] = "招架-急速"
L["Parry target list"] = "招架目标列表"
L["%s's parry targets"] = "%s的招架目标"
L["%s parried %s (%s)"] = "%s招架%s (%s)"
-- Potions module lines --
L["Potions"] = "药水"
L["Potions list"] = "药水列表"
L["Players list"] = "玩家列表"
L["%s's used potions"] = "%s使用的药水"
L["Pre-potion"] = "预使用药水"
L["pre-potion: %s"] = "预使用药水:%s"
L["Prints pre-potion after the end of the combat."] = "战斗结束后发布预使用药水讯息。"
-- healthstone --
L["Healthstones"] = "治疗石"
-- resurrect module lines --
L["Resurrects"] = "复活"
L["Resurrect spell list"] = "复活法术列表"
L["Resurrect target list"] = "复活目标列表"
L["%s's resurrect spells"] = "%s的复活法术"
L["%s's resurrect targets"] = "%s的复活目标"
-- nickname module lines --
L["Nickname"] = "昵称"
L["Nicknames are sent to group members and Skada can use them instead of your character name."] = "昵称已发送给队员，Skada可使用它取代你的角色名字。"
L["Set a nickname for you."] = "给自己设定一个昵称。"
L["Nickname isn't a valid string."] = "此昵称不是有效字符串。"
L["Your nickname is too long, max of 12 characters is allowed."] = "你的昵称太长，最多允许12个字符。"
L["Only letters and two spaces are allowed."] = "仅允许字母及2个空格。"
L["Your nickname contains a forbidden word."] = "您的昵称包含禁止词。"
L["You can't use the same letter three times consecutively, two spaces consecutively or more then two spaces."] = "同一个字母不能连续使用3次，不能连续使用2个空格且不能超过2个空格。"
L["Ignore Nicknames"] = "忽略昵称"
L["When enabled, nicknames set by Skada users are ignored."] = "勾选后，Skada用户设定的昵称将被忽略。"
L["Name display"] = "名字显示"
L["Choose how names are shown on your bars."] = "选择统计条上名字的显示方式。"
L["Clear Cache"] = "清除缓存"
L["Are you sure you want clear cached nicknames?"] = "您确定要清除缓存的昵称吗？"
-- overkill module lines --
L["Overkill"] = "过度杀伤"
L["Overkill spell list"] = "过度杀伤法术列表"
L["Overkill target list"] = "过度杀伤目标列表"
L["%s's overkill spells"] = "%s 过度杀伤法术"
L["%s's overkill targets"] = "%s 过度杀伤目标"
-- tweaks module lines --
L["Improvement"] = "提升"
L["Tweaks"] = "调整"
L["First hit"] = "第一击"
L["\124cffffff00First Hit\124r: %s from %s"] = "\124cffffff00第一击\124r : 从%2$s%1$s"
L["\124cffffbb00First Hit\124r: *?*"] = "\124cffffbb00First Hit\124r: *?*"
L["\124cffffbb00Boss First Target\124r: %s"] = "\124cffffbb00BOSS第一个目标\124r：%s"
L["opt_tweaks_firsthit_desc"] = "发布一条讯息，显示是谁施放了第一次攻击。\n仅对BOSS战有效。"
L["Filter DPS meters Spam"] = "过滤DPS统计的垃圾讯息"
L["opt_tweaks_spamage_desc"] = "阻止来自于伤害统计插件的聊天讯息，并提供一条简单的聊天链接，在弹出窗口中显示伤害统计信息。"
L["Reported by: %s"] = "报告者：%s"
L["Smart Stop"] = "智能停止"
L["opt_tweaks_smarthalt_desc"] = "BOSS死亡后自动停止当前分段。\n有助于避免在发生战斗BUG时收集数据。"
L["Duration"] = "等待時間"
L["opt_tweaks_smartwait_desc"] = "Skada 在停止該段之前應等待多長時間。"
L["Modes Icons"] = "模式图标"
L["Show modes icons on bars and menus."] = "在栏和菜单上显示模式图标。"
L["opt_tweaks_combatlogfix_desc"] = "从断裂而没有完全破坏它可以防止战斗记录。"
L["Conservative Mode"] = "保守的"
L["Aggressive Mode"] = "好斗的"
L["opt_tweaks_combatlogfixalt_desc"] = "不断清除战斗日志，而不是仅在它损坏时清除。"
L["%d filtered / %d events found. Cleared combat log, as it broke."] = "发现 %d 个过滤/%d 个事件。 清除战斗日志，因为它坏了。"
L["Enable this if you want to ignore \124cffffbb00%s\124r."] = "如果您想忽略\124cffffbb00%s\124r，请启用此功能。"
L["Custom Colors"] = "定制色彩"
L["Arena Teams"] = "竞技场队伍"
L["Are you sure you want to reset all colors?"] = "确定要重置所有颜色？"
L["Announce %s"] = "宣布：%s"
L["Announces how long it took to apply %d stacks of %s and announces when it drops."] = "宣布应用 %d 堆 %s 所用的时间，并宣布它何时到期。"
L["%s dropped from %s!"] = "%s 已于 %s 过期！"
L["%s stacks of %s applied on %s in %s sec!"] = "%4$s 秒内将 %1$s 叠 %2$s 涂抹在 %3$s 上！"
L["My Spells"] = "我的技能"
-- total data options
L["Total Segment"] = "总段" -- needs review
L["All Segments"] = "所有段" -- needs review
L["Raid Bosses"] = "突袭首领" -- needs review
L["Raid Trash"] = "突袭垃圾" -- needs review
L["Dungeon Bosses"] = "地牢首领" -- needs review
L["Dungeon Trash"] = "地牢垃圾" -- needs review
L["opt_tweaks_total_all_desc"] = "将所有段添加到总段的数据中。" -- needs review
L["opt_tweaks_total_fmt_desc"] = "将带有 %s 的段添加到总段的数据中。" -- needs review
L["Detailed total segment"] = "详细的总段"
-- L["opt_tweaks_total_full_desc"] = "When enabled, Skada will record everything to the total segment, instead of total numbers (record spell details, their targets as their sources)."
-- arena
L["mod_pvp_desc"] = "为竞技场和战场增加了专业化检测，并在同一窗口上显示竞技场的对手。"
L["Gold Team"] = "金队"
L["Green Team"] = "绿队"
L["Color for %s."] = "%s 的颜色。"
-- notifications
L["Notifications"] = "通知"
L["opt_toast_desc"] = "在适用时使用视觉通知而不是聊天窗口消息。"
L["Test Notifications"] = "测试通知"
-- comparison module
L["Comparison"] = "比较"
L["Damage Comparison"] = "伤害比较"
L["%s vs %s: %s"] = "%s 与 %s: %s"
L["%s vs %s: Spells"] = "%s 与 %s: 法术"
L["%s vs %s: Targets"] = "%s 与 %s: 目标"
L["%s vs %s: Damage on %s"] = "%s 与 %s: %s上的伤害"
-- about
L["About"] = "关于"
L["Author"] = "作者"
L["Credits"] = "鸣谢"
L["Date"] = "日期"
L["Discord"] = "Discord"
L["License"] = "许可"
L["Version"] = "版本"
L["Website"] = "网站"
-- some bosses entries
L["World Boss"] = "世界首领"
L["Acidmaw"] = "酸喉"
L["Auriaya"] = "欧尔莉亚"
L["Blood Prince Council"] = "鲜血王子议会"
L["Champions of the Alliance"] = "联盟的冠军"
L["Champions of the Horde"] = "部落的冠军"
L["Cult Adherent"] = "教派追随者"
L["Cult Fanatic"] = "教派狂热者"
L["Darnavan"] = "达尔纳文"
L["Deformed Fanatic"] = "畸形的狂热者"
L["Dreadscale"] = "恐鳞"
L["Empowered Adherent"] = "亢奋的追随者"
L["Faction Champions"] = "阵营冠军"
L["Gas Cloud"] = "毒气之云"
L["General Vezax"] = "维扎克斯将军"
L["Gluth"] = "格拉斯"
L["Halion"] = "海里昂"
L["Hogger"] = "霍格"
L["Ice Sphere"] = "寒冰之球"
L["Icecrown Gunship Battle"] = "冰冠炮舰战斗"
L["Icehowl"] = "冰吼"
L["Kel'Thuzad"] = "克尔苏加德"
L["Kologarn"] = "科隆加恩"
L["Lady Deathwhisper"] = "亡语者女士"
L["Living Inferno"] = "活体地狱火"
L["Mimiron"] = "米米尔隆"
L["Onyxia"] = "奥妮克希亚"
L["Prince Keleseth"] = "凯雷塞斯王子"
L["Prince Taldaram"] = "塔达拉姆王子"
L["Prince Valanar"] = "瓦拉纳王子"
L["Raging Spirit"] = "暴怒的灵魂"
L["Reanimated Adherent"] = "被复活的追随者"
L["Reanimated Fanatic"] = "被复活的狂热者"
L["Sapphiron"] = "萨菲隆"
L["Shambling Horror"] = "蹒跚的血僵尸"
L["Sindragosa"] = "辛达苟萨"
L["Thaddius"] = "塔迪乌斯"
L["The Four Horsemen"] = "四骑士"
L["The Iron Council"] = "钢铁议会"
L["The Lich King"] = "巫妖王"
L["The Northrend Beasts"] = "诺森德猛兽"
L["Thorim"] = "托里姆"
L["Twin Val'kyr"] = "瓦格里双子"
L["Val'kyr Shadowguard"] = "瓦格里暗影戒卫者"
L["Valithria Dreamwalker"] = "踏梦者瓦莉瑟瑞娅"
L["Volatile Ooze"] = "不稳定的软泥怪"
L["Wicked Spirit"] = "卑劣的灵魂"
L["Yogg-Saron"] = "尤格-萨隆"
