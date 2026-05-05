local AH = _G.AH or _G.AttuneHelper
if not AH then return end

local LINE_TEX = "Interface\\AddOns\\AttuneHelper\\assets\\white8x8.blp"

local BLUE_THEME = {
    panelBg = { 0.04, 0.07, 0.14, 0.94 },
    panelBorder = { 0.22, 0.48, 0.82, 0.95 },
    subtitle = { 0.68, 0.78, 0.94 },
    tabActive = { 0.62, 0.84, 1.0 },
    tabInactive = { 0.78, 0.83, 0.92 },
}

local METRICS = {
    { key = "account", label = "Account", tipShort = "Account", deltaField = "dAccount", seriesField = "account", tipTitle = "account attunes" },
    { key = "titanforged", label = "TF", tipShort = "TF", deltaField = "dTitanforged", seriesField = "titanforged", tipTitle = "titanforged attunes" },
    { key = "warforged", label = "WF", tipShort = "WF", deltaField = "dWarforged", seriesField = "warforged", tipTitle = "warforged attunes" },
    { key = "lightforged", label = "LF", tipShort = "LF", deltaField = "dLightforged", seriesField = "lightforged", tipTitle = "lightforged attunes" },
}

--[[ ASCENT TIER / ACHIEVEMENT SYSTEM (disabled — uncomment block + badge UI below to restore)
local PEAK_ICONS = {
    "Interface\\Icons\\achievement_boss_mutanus_the_devourer",
    "Interface\\Icons\\achievement_boss_bazil_thredd",
    "Interface\\Icons\\achievement_boss_aeonus_01",
    "Interface\\Icons\\achievement_boss_amnennar_the_coldbringer",
    "Interface\\Icons\\achievement_boss_chiefukorzsandscalp",
    "Interface\\Icons\\achievement_boss_cthun",
    "Interface\\Icons\\achievement_boss_kingymiron_03",
    "Interface\\Icons\\achievement_boss_ragnaros",
    "Interface\\Icons\\achievement_boss_princemalchezaar_02",
}

local PEAK_ACHIEVE = {
    { name = "First Bite of the Day", flavor = "The day felt quiet until your totals moved. That first spike of attunes is the hardest — you already broke the ice. Let the rest of the session ride that energy." },
    { name = "Defias Downpayment", flavor = "Stormwind's sewers would file a complaint if they could. You're stacking real clears, not just parking alts — keep the tempo and the chart turns into a brag reel." },
    { name = "Hourglass Heroics", flavor = "Aeonus would check his watch and flinch. You're outpacing the usual crawl: more keys, more shine, more reasons for the forge row to glow." },
    { name = "Crypt Cold Front", flavor = "Frostbloom on the meter — your LF and account lines are whispering 'raid night ready'. Lean into the chill; consistency here feels unfair to the calendar." },
    { name = "Sandfury Momentum", flavor = "Ukorz respects volume. You're not dabbling anymore — this is the bracket where friends start side-eyeing your daily totals in the best way." },
    { name = "Temple Pressure", flavor = "Eye of the chart: open. You're operating at 'raid lead raised an eyebrow' levels for a single day. Protect this streak like it's a world buff." },
    { name = "Vrykul Victory Lap", flavor = "Ymiron's hall would echo if it saw these numbers. You're in the rare air where one more focused push could turn today into a story you retell." },
    { name = "Core Temperature Rising", flavor = "Ragnaros nods — molten-tier focus. Few players tick this many boxes before dinner. Finish strong and let the reset screenshot itself." },
    { name = "Chessboard Cleared", flavor = "Prince-tier swagger. If today were a raid ID, you'd be saving this one to disk. Ride the high — then come back tomorrow and make the chart jealous again." },
}

local function PeakEncouragement(tier, peakScore, a, tf, wf, lf)
    if tier >= 9 then
        return "You capped the ascent ladder for that history day. Screenshot energy — then beat it on the next snapshot boundary."
    end
    if tier <= 2 then
        return "Climb the ladder: chase a fatter TF column, a spicy WF streak, or a chunk of account clears before reset. Every icon you unlock is pure dopamine."
    end
    if tier <= 5 then
        return "Mid tiers love a double play: stack account clears while you chase blues and oranges. Lightforged bumps score fast if you can squeeze them in."
    end
    return "You're in the raid-boss bracket. One loud account session or a triple-forge burst can crown the day — push before the clock wins."
end
]]

local function fmtNum(n)
    n = math.floor(tonumber(n) or 0)
    local neg = n < 0
    n = math.abs(n)
    local s = tostring(n)
    local k = #s % 3
    if k == 0 then
        k = 3
    end
    local out = s:sub(1, k)
    for j = k + 1, #s, 3 do
        out = out .. "," .. s:sub(j, j + 2)
    end
    return (neg and "-" or "") .. out
end

local COLOR_ACCOUNT = { 1, 0.92, 0.55 }
local COLOR_TF = { 0.55, 0.78, 1 }
local COLOR_WF = { 1, 0.62, 0.38 }
local COLOR_LF = { 1, 0.92, 0.45 }
local COLOR_PLOT = { 0.35, 0.72, 1 }

local function Rgb255(rgb)
    return math.floor(rgb[1] * 255), math.floor(rgb[2] * 255), math.floor(rgb[3] * 255)
end

local function fmtHistoryAccountLine(total, delta)
    if delta == nil then
        return string.format("|cffffffffAccount %s|r", fmtNum(total))
    end
    local d = math.max(0, tonumber(delta) or 0)
    local r, g, b = Rgb255(COLOR_ACCOUNT)
    return string.format("|cffffffffAccount %s|r |cff%02x%02x%02x(+%s)|r", fmtNum(total), r, g, b, fmtNum(d))
end

local function fmtHistoryMetricLine(label, total, delta, rgb)
    local r, g, b = Rgb255(rgb)
    if delta == nil then
        return string.format("|cff%02x%02x%02x%s|r |cffffffff%s|r", r, g, b, label, fmtNum(total))
    end
    local d = math.max(0, tonumber(delta) or 0)
    return string.format("|cff%02x%02x%02x%s|r |cffffffff%s|r |cff%02x%02x%02x(+%s)|r", r, g, b, label, fmtNum(total), r, g, b, fmtNum(d))
end

local dash
local RefreshListPreview
local RefreshSnapshotBadges

local function CreatePanel(parent, width, height, point, relativeTo, relativePoint, x, y)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, height)
    frame:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(unpack(BLUE_THEME.panelBg))
    frame:SetBackdropBorderColor(unpack(BLUE_THEME.panelBorder))
    return frame
end

local function CreateText(parent, template, point, relativeTo, relativePoint, x, y, width, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
    fs:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
    if width then fs:SetWidth(width) end
    if justify then fs:SetJustifyH(justify) end
    return fs
end

local function CreateClickPanel(parent, width, height, point, relativeTo, relativePoint, x, y, label, onClick)
    local button = CreatePanel(parent, width, height, point, relativeTo, relativePoint, x, y)
    button:EnableMouse(true)
    button.text = CreateText(button, "GameFontNormalSmall", "CENTER", button, "CENTER", 0, 0)
    button.text:SetText(label)
    button.text:SetTextColor(unpack(BLUE_THEME.tabInactive))
    button:SetScript("OnMouseUp", function(_, btn)
        if btn == "LeftButton" and onClick then onClick() end
    end)
    return button
end

local function MetricDef(key)
    for _, m in ipairs(METRICS) do
        if m.key == key then return m end
    end
    return METRICS[1]
end

local function GetDelta(row, deltaField)
    return row[deltaField]
end

local function ReleaseTexturePool(pool)
    if not pool then return end
    for _, t in ipairs(pool) do
        t:Hide()
    end
end

local function AcquireTexture(pool, parent)
    for _, t in ipairs(pool) do
        if not t:IsShown() then
            return t
        end
    end
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture(LINE_TEX)
    tinsert(pool, t)
    return t
end

local function PlotX(i, n, plotW)
    if n <= 1 then return plotW * 0.5 end
    return (i - 1) * (plotW / (n - 1))
end

local function RefreshSidebar()
    if not dash or not dash.snapshotDate then return end
    if AH.EnsureDailyAttuneSnapshotCurrent then
        AH.EnsureDailyAttuneSnapshotCurrent()
    end

    local series = AH.GetDailyAttuneHistorySeries and AH.GetDailyAttuneHistorySeries() or {}
    local last = series[#series]

    if last then
        dash.snapshotDate:SetText(tostring(last.date or "---"))
        dash.snapAccount:SetText(fmtHistoryAccountLine(last.account, last.dAccount))
        dash.snapTF:SetText(fmtHistoryMetricLine("TF", last.titanforged, last.dTitanforged, COLOR_TF))
        dash.snapWF:SetText(fmtHistoryMetricLine("WF", last.warforged, last.dWarforged, COLOR_WF))
        dash.snapLF:SetText(fmtHistoryMetricLine("LF", last.lightforged, last.dLightforged, COLOR_LF))
    else
        dash.snapshotDate:SetText("---")
        dash.snapAccount:SetText("|cffffffffAccount —|r")
        dash.snapTF:SetText("|cff888888TF —|r")
        dash.snapWF:SetText("|cff888888WF —|r")
        dash.snapLF:SetText("|cff888888LF —|r")
    end

    local font = AH.FONT_EXPRESSWAY or "Fonts\\FRIZQT__.TTF"
    dash.snapshotDate:SetFont(font, 16, "OUTLINE")
    dash.snapAccount:SetFont(font, 14, "OUTLINE")
    dash.snapTF:SetFont(font, 13, "OUTLINE")
    dash.snapWF:SetFont(font, 13, "OUTLINE")
    dash.snapLF:SetFont(font, 13, "OUTLINE")
    if dash.snapHeader then
        dash.snapHeader:SetFont(font, 11, "OUTLINE")
    end

    RefreshSnapshotBadges(series)
end

local function RefreshMetricToggleColors()
    if not dash then return end
    for _, m in ipairs(METRICS) do
        local b = dash.metricBtns[m.key]
        if b then
            if dash.metricKey == m.key then
                b.text:SetTextColor(unpack(BLUE_THEME.tabActive))
            else
                b.text:SetTextColor(unpack(BLUE_THEME.tabInactive))
            end
        end
    end
end

local function RefreshModeToggleColors()
    if not dash then return end
    local activeP = dash.chartMode == "plot" and BLUE_THEME.tabActive or BLUE_THEME.tabInactive
    local activeB = dash.chartMode == "bars" and BLUE_THEME.tabActive or BLUE_THEME.tabInactive
    dash.modePlot.text:SetTextColor(activeP[1], activeP[2], activeP[3])
    dash.modeBars.text:SetTextColor(activeB[1], activeB[2], activeB[3])
end

local function FormatDeltaParen(d)
    if d == nil then return "(no prior day)" end
    local n = tonumber(d) or 0
    if n >= 0 then
        return string.format("(+%s)", fmtNum(n))
    end
    return string.format("(%s)", fmtNum(n))
end
-- DO NOT UNCOMMENT OR YOU WILL START CRINGING UNCONTROLLABLY
-- YOU ARE WARNED
--[[ ASCENT TIER / ACHIEVEMENT SYSTEM (disabled — helpers + badge refresh; uncomment with block above + snapBadgeRow in Build)
local function MaxPastDelta(series, todayKey, field)
    local best = 0
    for _, row in ipairs(series) do
        if tostring(row.date or "") ~= todayKey then
            local v = row[field]
            if v and v > best then
                best = v
            end
        end
    end
    return best
end

local function BuildSnapshotBadgeList(series)
    local out = {}
    local last = series and series[#series]
    if not last or last.dAccount == nil then
        return out
    end

    local focusKey = tostring(last.date or "")
    local a = math.max(0, tonumber(last.dAccount) or 0)
    local tf = math.max(0, tonumber(last.dTitanforged) or 0)
    local wf = math.max(0, tonumber(last.dWarforged) or 0)
    local lf = math.max(0, tonumber(last.dLightforged) or 0)
    if a + tf + wf + lf <= 0 then
        return out
    end

    local maxPastA = MaxPastDelta(series, focusKey, "dAccount")
    local maxPastTf = MaxPastDelta(series, focusKey, "dTitanforged")
    local maxPastWf = MaxPastDelta(series, focusKey, "dWarforged")
    local maxPastLf = MaxPastDelta(series, focusKey, "dLightforged")
    local forgeSum = tf + wf + lf

    local recordAccount = maxPastA > 0 and a > maxPastA
    local recordTf = maxPastTf > 0 and tf > maxPastTf
    local recordWf = maxPastWf > 0 and wf > maxPastWf
    local recordLf = maxPastLf > 0 and lf > maxPastLf

    local peakScore = a + tf * 2 + wf * 2.5 + lf * 4
    if recordAccount then peakScore = peakScore + 12 end
    if recordTf then peakScore = peakScore + 8 end
    if recordWf then peakScore = peakScore + 8 end
    if recordLf then peakScore = peakScore + 10 end

    local goodDay = peakScore >= 52
        or a >= 30
        or tf >= 12
        or (tf >= 8 and wf >= 2)
        or (a >= 20 and forgeSum >= 14)
        or (forgeSum >= 24 and (tf >= 8 or wf >= 4))
        or (recordAccount and a >= 18)
        or (recordTf and tf >= 10)
        or lf >= 4

    if not goodDay then
        return out
    end

    local tier = math.min(9, math.max(1, math.floor(math.max(0, peakScore - 34) / 15) + 1))

    local cta = PeakEncouragement(tier, peakScore, a, tf, wf, lf)
    local statsLine = string.format(
        "That day's snapshot step: |cffffffff+%s|r account   |cff88ccff+%s|r TF   |cffffaa66+%s|r WF   |cffffee88+%s|r LF vs the prior recorded day.",
        fmtNum(a), fmtNum(tf), fmtNum(wf), fmtNum(lf)
    )

    for step = 1, tier do
        local icon = PEAK_ICONS[step]
        local row = PEAK_ACHIEVE[step]
        if icon and row then
            tinsert(out, {
                icon = icon,
                title = row.name,
                subtitle = string.format("Daily Ascent · milestone %d of %d", step, tier),
                flavor = row.flavor,
                statsLine = statsLine,
                cta = cta,
            })
        end
    end

    return out
end

local function EnsureSnapshotBadgeSlot(parent, index)
    dash.snapBadgeBtns = dash.snapBadgeBtns or {}
    local b = dash.snapBadgeBtns[index]
    if not b then
        b = CreateFrame("Frame", nil, parent)
        b:SetSize(30, 30)
        b:EnableMouse(true)
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetPoint("CENTER", b, "CENTER", 0, 0)
        b.icon:SetWidth(26)
        b.icon:SetHeight(26)
        b:SetScript("OnEnter", function(self)
            if self.icon then
                self.icon:SetWidth(28)
                self.icon:SetHeight(28)
            end
            if not self._tipTitle then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self._tipTitle, 1, 0.82, 0.1)
            if self._tipSubtitle then
                GameTooltip:AddLine(self._tipSubtitle, 0.72, 0.78, 0.92, false)
            end
            if self._tipFlavor then
                GameTooltip:AddLine(self._tipFlavor, 1, 0.96, 0.88, true)
            end
            if self._tipStats then
                GameTooltip:AddLine(self._tipStats, 0.82, 0.9, 1, true)
            end
            if self._tipCta then
                GameTooltip:AddLine(self._tipCta, 0.5, 0.98, 0.68, true)
            end
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function(self)
            if self.icon then
                self.icon:SetWidth(26)
                self.icon:SetHeight(26)
            end
            GameTooltip_Hide()
        end)
        dash.snapBadgeBtns[index] = b
    end
    return b
end

RefreshSnapshotBadges = function(series)
    if not dash or not dash.snapBadgeRow then return end
    dash.snapBadgeBtns = dash.snapBadgeBtns or {}
    for _, b in ipairs(dash.snapBadgeBtns) do
        b:Hide()
    end

    local list = BuildSnapshotBadgeList(series or {})
    local n = #list
    if n == 0 then
        dash.snapBadgeRow:SetHeight(1)
        dash.snapBadgeRow:Hide()
        return
    end

    dash.snapBadgeRow:Show()
    dash.snapBadgeRow:SetHeight(32)

    local rowW = dash.snapBadgeRow:GetWidth() or 196
    local spacing = 26
    if n > 1 then
        spacing = math.min(26, math.floor((rowW - 24) / (n - 1)))
        spacing = math.max(16, spacing)
    end
    local startX = -((n - 1) * spacing) * 0.5
    for i = 1, n do
        local def = list[i]
        local b = EnsureSnapshotBadgeSlot(dash.snapBadgeRow, i)
        b._tipTitle = def.title
        b._tipSubtitle = def.subtitle
        b._tipFlavor = def.flavor
        b._tipStats = def.statsLine
        b._tipCta = def.cta
        b.icon:SetTexture(def.icon)
        b:ClearAllPoints()
        b:SetPoint("TOP", dash.snapBadgeRow, "TOP", startX + (i - 1) * spacing, -1)
        b:Show()
    end
end
]]

RefreshSnapshotBadges = function(_series)
    if dash and dash.snapBadgeRow then
        dash.snapBadgeRow:SetHeight(1)
        dash.snapBadgeRow:Hide()
    end
end

local function ShowTooltipIndex(idx)
    if not dash or not dash.series or idx < 1 or idx > #dash.series then
        return
    end

    local row = dash.series[idx]
    local m = MetricDef(dash.metricKey)
    local label = m.tipShort or m.label

    GameTooltip:SetOwner(dash.plotFrame or UIParent, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(row.date, 1, 1, 1)

    local dv = GetDelta(row, m.deltaField)
    if dv ~= nil then
        GameTooltip:AddLine(string.format("%s: +%s", label, fmtNum(dv)), 1, 0.92, 0.55)
    else
        GameTooltip:AddLine("No prior recorded day for deltas.", 0.75, 0.75, 0.75, true)
    end

    if row.dAccount ~= nil then
        GameTooltip:AddLine(string.format("Account: %s %s", fmtNum(row.account), FormatDeltaParen(row.dAccount)), COLOR_ACCOUNT[1], COLOR_ACCOUNT[2], COLOR_ACCOUNT[3])
    else
        GameTooltip:AddLine(string.format("Account: %s", fmtNum(row.account)), 1, 1, 1)
    end
    GameTooltip:AddLine(string.format("TF: %s %s", fmtNum(row.titanforged), FormatDeltaParen(row.dTitanforged)), COLOR_TF[1], COLOR_TF[2], COLOR_TF[3])
    GameTooltip:AddLine(string.format("WF: %s %s", fmtNum(row.warforged), FormatDeltaParen(row.dWarforged)), COLOR_WF[1], COLOR_WF[2], COLOR_WF[3])
    GameTooltip:AddLine(string.format("LF: %s %s", fmtNum(row.lightforged), FormatDeltaParen(row.dLightforged)), COLOR_LF[1], COLOR_LF[2], COLOR_LF[3])
    GameTooltip:Show()
end

local function HideTooltip()
    GameTooltip:Hide()
end

local function ApplyPlotChrome(plotH)
    if not dash or not dash.plotFrame or not dash.chartPanel then return end
    local plotFrame = dash.plotFrame
    local chartPanel = dash.chartPanel
    plotFrame:ClearAllPoints()
    plotFrame:SetPoint("TOPLEFT", chartPanel, "TOPLEFT", 10, -56)
    plotFrame:SetPoint("TOPRIGHT", chartPanel, "TOPRIGHT", -10, -56)
    plotFrame:SetHeight(plotH)
    if dash.listShown then
        dash.listScroll:ClearAllPoints()
        dash.listScroll:SetPoint("TOPLEFT", plotFrame, "BOTTOMLEFT", 0, -8)
        dash.listScroll:SetPoint("TOPRIGHT", plotFrame, "BOTTOMRIGHT", 0, -8)
        dash.listScroll:SetHeight(88)
        dash.chartFooter:ClearAllPoints()
        dash.chartFooter:SetPoint("BOTTOMLEFT", chartPanel, "BOTTOMLEFT", 12, 108)
        dash.listToggle:ClearAllPoints()
        dash.listToggle:SetPoint("BOTTOMLEFT", chartPanel, "BOTTOMLEFT", 10, 10)
        dash.listScroll:Show()
    else
        dash.listScroll:Hide()
        dash.chartFooter:ClearAllPoints()
        dash.chartFooter:SetPoint("BOTTOMLEFT", chartPanel, "BOTTOMLEFT", 12, 42)
        dash.listToggle:ClearAllPoints()
        dash.listToggle:SetPoint("BOTTOMLEFT", chartPanel, "BOTTOMLEFT", 10, 10)
    end
end

RefreshListPreview = function()
    if not dash then return end
    local series = dash.series or {}
    if not dash.listShown then
        dash.listScroll:Hide()
        return
    end

    dash.listScroll:Show()
    local sw = dash.listScroll:GetWidth()
    if sw and sw > 24 then
        dash.listScrollChild:SetWidth(sw - 24)
    end
    local sorted = {}
    for i = #series, 1, -1 do
        sorted[#sorted + 1] = series[i]
    end

    local rowH = 18
    local maxRows = 40
    local shown = math.min(#sorted, maxRows)
    dash.listScrollChild:SetHeight(math.max(40, shown * rowH + 8))

    for i = 1, maxRows do
        local fs = dash.listRows[i]
        local row = sorted[i]
        if row then
            local line = string.format("%s  dA:%s dTF:%s dWF:%s dLF:%s  |  A:%s TF:%s WF:%s LF:%s",
                row.date,
                row.dAccount ~= nil and fmtNum(row.dAccount) or "-",
                row.dTitanforged ~= nil and fmtNum(row.dTitanforged) or "-",
                row.dWarforged ~= nil and fmtNum(row.dWarforged) or "-",
                row.dLightforged ~= nil and fmtNum(row.dLightforged) or "-",
                fmtNum(row.account), fmtNum(row.titanforged), fmtNum(row.warforged), fmtNum(row.lightforged))
            fs:SetText(line)
            fs:Show()
        else
            fs:SetText("")
            fs:Hide()
        end
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", dash.listScrollChild, "TOPLEFT", 8, -6 - (i - 1) * rowH)
    end
end

local function RefreshChart()
    if not dash then return end

    ReleaseTexturePool(dash.linePool)
    ReleaseTexturePool(dash.markerPool)
    ReleaseTexturePool(dash.gridPool)
    ReleaseTexturePool(dash.barPool)
    dash.band:Hide()

    for _, fs in ipairs(dash.axisLabels) do
        fs:Hide()
    end

    dash.series = AH.GetDailyAttuneHistorySeries and AH.GetDailyAttuneHistorySeries() or {}
    local series = dash.series
    local n = #series
    local m = MetricDef(dash.metricKey)

    dash.chartSubtitle:SetTextColor(unpack(BLUE_THEME.subtitle))

    local plotH = dash.listShown and 148 or 252
    ApplyPlotChrome(plotH)

    if n == 0 then
        dash.plotGeom = nil
        dash.chartSubtitle:SetText("Daily gain (between recorded days) - no data.")
        dash.chartFooter:SetText("")
        dash.hoverIdx = nil
        HideTooltip()
        SyncPlotHoverStrips(dash.plotFrame, 0, 0, 0, 0, 0)
        RefreshListPreview()
        return
    end

    local vmin = 0
    local vmax = 1
    for i = 1, n do
        local v = GetDelta(series[i], m.deltaField)
        if v ~= nil then
            vmax = math.max(vmax, v)
        end
    end
    local pad = math.max(1, vmax * 0.08)
    vmax = vmax + pad

    local firstDate = series[1].date
    local lastDate = series[n].date
    dash.chartSubtitle:SetText(string.format(
        "Daily gain scale %.0f-%.0f | %s to %s (between recorded days)",
        vmin, vmax, firstDate, lastDate
    ))

    local sumD, cntD = 0, 0
    for i = 1, n do
        local d = GetDelta(series[i], m.deltaField)
        if d ~= nil then
            sumD = sumD + d
            cntD = cntD + 1
        end
    end
    local avg = cntD > 0 and (sumD / cntD) or 0
    dash.chartFooter:SetText(string.format("%s attunes/day avg over chart: %.1f (%d intervals)", m.label, avg, cntD))

    local plotFrame = dash.plotFrame

    local pw = plotFrame:GetWidth() - 8
    local ph = plotFrame:GetHeight() - 28
    local padX, padY = 4, 4

    for g = 0, 4 do
        local gy = padY + (ph * g / 4)
        local t = AcquireTexture(dash.gridPool, plotFrame)
        t:SetVertexColor(0.5, 0.55, 0.65, 0.22)
        t:SetHeight(1)
        t:SetWidth(pw)
        if t.SetRotation then
            t:SetRotation(0)
        end
        t:ClearAllPoints()
        t:SetPoint("BOTTOMLEFT", plotFrame, "BOTTOMLEFT", padX, gy)
        t:Show()
    end

    local function YFor(v)
        local denom = math.max(vmax - vmin, 1e-6)
        local vn = (v - vmin) / denom
        return padY + vn * ph
    end

    if dash.chartMode == "bars" then
        local slot = pw / math.max(n, 1)
        local bw = math.min(slot * 0.65, pw / math.max(n * 1.2, 1))
        bw = math.max(4, math.min(bw, pw * 0.5))
        if bw > pw - 2 then
            bw = math.max(4, pw - 2)
        end
        for i = 1, n do
            local dv = GetDelta(series[i], m.deltaField) or 0
            local xMid = PlotX(i, n, pw)
            xMid = math.max(bw * 0.5, math.min(pw - bw * 0.5, xMid))
            local yTop = YFor(math.max(dv, 0))
            local yBot = YFor(0)
            local h = math.max(yTop - yBot, 1)
            local left = padX + xMid - bw * 0.5
            if left < padX then
                left = padX
            end
            if left + bw > padX + pw then
                left = padX + pw - bw
            end
            local t = AcquireTexture(dash.barPool, plotFrame)
            t:SetVertexColor(COLOR_PLOT[1], COLOR_PLOT[2], COLOR_PLOT[3], 0.85)
            t:SetWidth(bw)
            t:SetHeight(h)
            if t.SetRotation then
                t:SetRotation(0)
            end
            t:ClearAllPoints()
            t:SetPoint("BOTTOMLEFT", plotFrame, "BOTTOMLEFT", left, yBot)
            t:Show()
        end
    else
        local function DrawStippledSegment(x0, y0, x1, y1)
            local dx = x1 - x0
            local dy = y1 - y0
            local len = math.sqrt(dx * dx + dy * dy)
            if len < 0.5 then
                return
            end
            local steps = math.min(32, math.max(2, math.ceil(len / 3)))
            for s = 0, steps do
                local t = s / steps
                local px = x0 + dx * t
                local py = y0 + dy * t
                local seg = AcquireTexture(dash.linePool, plotFrame)
                seg:SetVertexColor(COLOR_PLOT[1], COLOR_PLOT[2], COLOR_PLOT[3], 1)
                seg:SetWidth(3)
                seg:SetHeight(3)
                if seg.SetRotation then
                    seg:SetRotation(0)
                end
                seg:ClearAllPoints()
                seg:SetPoint("CENTER", plotFrame, "BOTTOMLEFT", px, py)
                seg:Show()
            end
        end

        local prevX, prevY
        for i = 1, n do
            local dv = GetDelta(series[i], m.deltaField) or 0
            local xi = padX + PlotX(i, n, pw)
            local yi = YFor(dv)
            if prevX then
                DrawStippledSegment(prevX, prevY, xi, yi)
            end
            prevX, prevY = xi, yi

            local dot = AcquireTexture(dash.markerPool, plotFrame)
            dot:SetVertexColor(0.85, 0.92, 1, 1)
            dot:SetWidth(7)
            dot:SetHeight(7)
            if dot.SetRotation then
                dot:SetRotation(0)
            end
            dot:ClearAllPoints()
            dot:SetPoint("CENTER", plotFrame, "BOTTOMLEFT", xi, yi)
            dot:Show()
        end
    end

    local labelSlots = { 1, math.ceil(n * 0.33), math.ceil(n * 0.66), n }
    local seen = {}
    local li = 1
    for _, si in ipairs(labelSlots) do
        if si >= 1 and si <= n and not seen[si] then
            seen[si] = true
            local fs = dash.axisLabels[li]
            if not fs then
                fs = CreateText(plotFrame, "GameFontNormalSmall", "TOP", plotFrame, "BOTTOMLEFT", padX + PlotX(si, n, pw), -4)
                dash.axisLabels[li] = fs
            end
            fs:ClearAllPoints()
            local xd = padX + PlotX(si, n, pw)
            fs:SetPoint("TOP", plotFrame, "BOTTOMLEFT", xd, -4)
            local dk = series[si].date
            local short = dk
            if strlen(dk or "") >= 10 then
                short = strsub(dk, 6, 10)
            end
            fs:SetText(short or "")
            fs:SetTextColor(unpack(BLUE_THEME.subtitle))
            fs:Show()
            li = li + 1
        end
    end

    dash.plotGeom = { pw = pw, ph = ph, padX = padX, padY = padY, n = n }

    SyncPlotHoverStrips(plotFrame, n, pw, ph, padX, padY)

    RefreshListPreview()
end

local function ScheduleTooltipHideIfLeftPlot()
    local plotFrame = dash and dash.plotFrame
    if not plotFrame then return end
    local token = GetTime()
    dash._plotHoverLeaveToken = token
    if AH.Wait then
        AH.Wait(0.06, function()
            if not dash or dash._plotHoverLeaveToken ~= token then return end
            if MouseIsOver(plotFrame) then return end
            dash.hoverIdx = nil
            if dash.band then dash.band:Hide() end
            HideTooltip()
        end)
    else
        dash.hoverIdx = nil
        if dash.band then dash.band:Hide() end
        HideTooltip()
    end
end

function SyncPlotHoverStrips(plotFrame, n, pw, ph, padX, padY)
    if not dash then return end
    dash.pickStrips = dash.pickStrips or {}
    local strips = dash.pickStrips
    for i = 1, #strips do
        strips[i]:Hide()
    end
    if n <= 0 or not plotFrame then return end

    local plotH = plotFrame:GetHeight()

    for i = 1, n do
        local leftRel = (i <= 1) and 0 or ((PlotX(i - 1, n, pw) + PlotX(i, n, pw)) * 0.5)
        local rightRel = (i >= n) and pw or ((PlotX(i, n, pw) + PlotX(i + 1, n, pw)) * 0.5)
        local w = math.max(12, rightRel - leftRel)
        local left = padX + leftRel

        local strip = strips[i]
        if not strip then
            strip = CreateFrame("Frame", nil, plotFrame)
            strip:SetFrameStrata(plotFrame:GetFrameStrata() or "MEDIUM")
            strip:SetFrameLevel((plotFrame:GetFrameLevel() or 0) + 30)
            strip:EnableMouse(true)
            strips[i] = strip
            strip:SetScript("OnEnter", function(self)
                if not dash then return end
                local idx = self._pickIdx
                if not idx or not dash.plotGeom then return end
                dash.hoverIdx = idx
                local g = dash.plotGeom
                local xi = g.padX + PlotX(idx, g.n, g.pw)
                dash.band:SetWidth(12)
                dash.band:SetHeight(math.max(plotFrame:GetHeight(), g.ph + 8))
                dash.band:SetVertexColor(0.35, 0.65, 1, 0.18)
                dash.band:ClearAllPoints()
                dash.band:SetPoint("BOTTOMLEFT", dash.plotFrame, "BOTTOMLEFT", xi - 6, 0)
                dash.band:Show()
                ShowTooltipIndex(idx)
            end)
            strip:SetScript("OnLeave", ScheduleTooltipHideIfLeftPlot)
        end

        strip._pickIdx = i
        strip:SetParent(plotFrame)
        strip:SetHeight(math.max(plotH, ph + padY + 12))
        strip:SetWidth(w)
        strip:ClearAllPoints()
        strip:SetPoint("BOTTOMLEFT", plotFrame, "BOTTOMLEFT", left, 0)
        strip:Show()
    end
end

function AH.RefreshAttuneHistoryDashboard()
    if not dash then return end
    RefreshSidebar()
    RefreshMetricToggleColors()
    RefreshModeToggleColors()
    RefreshChart()
end

function AH.BuildAttuneHistoryDashboard(section)
    if dash then return end

    local root = CreatePanel(section, 984, 558, "TOPLEFT", section, "TOPLEFT", 0, 0)
    root:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", 0, 0)

    CreateText(root, "GameFontNormalLarge", "TOPLEFT", root, "TOPLEFT", 14, -12):SetText("Attune History")
    CreateText(root, "GameFontNormalSmall", "TOPLEFT", root, "TOPLEFT", 14, -36, 920, "LEFT"):SetText(
        "Archived totals when each game day rolled over. Day/day deltas compare consecutive recorded rows only (gaps are normal)."
    )

    local snapshotPanel = CreatePanel(root, 212, 120, "TOPLEFT", root, "TOPLEFT", 14, -62)
    snapshotPanel:SetPoint("BOTTOMLEFT", root, "BOTTOMLEFT", 14, 50)

    local snapHeader = CreateText(snapshotPanel, "GameFontNormalSmall", "TOP", snapshotPanel, "TOP", 0, -8, 196, "CENTER")
    snapHeader:SetText("Last history day")
    snapHeader:SetTextColor(unpack(BLUE_THEME.subtitle))
    snapHeader:SetJustifyH("CENTER")

    local snapDate = CreateText(snapshotPanel, "GameFontHighlightLarge", "TOP", snapHeader, "BOTTOM", 0, -6, 196, "CENTER")
    snapDate:SetJustifyH("CENTER")

    local snapAccount = CreateText(snapshotPanel, "GameFontNormalLarge", "TOP", snapDate, "BOTTOM", 0, -10, 196, "CENTER")
    snapAccount:SetJustifyH("CENTER")
    local snapTF = CreateText(snapshotPanel, "GameFontNormalLarge", "TOP", snapAccount, "BOTTOM", 0, -8, 196, "CENTER")
    snapTF:SetJustifyH("CENTER")
    local snapWF = CreateText(snapshotPanel, "GameFontNormalLarge", "TOP", snapTF, "BOTTOM", 0, -6, 196, "CENTER")
    snapWF:SetJustifyH("CENTER")
    local snapLF = CreateText(snapshotPanel, "GameFontNormalLarge", "TOP", snapWF, "BOTTOM", 0, -6, 196, "CENTER")
    snapLF:SetJustifyH("CENTER")

    --[[ ASCENT badge row (disabled with ascent system above)
    local snapBadgeRow = CreateFrame("Frame", nil, snapshotPanel)
    snapBadgeRow:SetWidth(196)
    snapBadgeRow:SetHeight(1)
    snapBadgeRow:SetPoint("TOP", snapLF, "BOTTOM", 0, -8)
    snapBadgeRow:Hide()
    ]]
    local snapBadgeRow = nil

    local chartPanel = CreatePanel(root, 200, 120, "TOPLEFT", snapshotPanel, "TOPRIGHT", 12, 0)
    chartPanel:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT", -14, 50)

    CreateText(chartPanel, "GameFontNormalLarge", "TOPLEFT", chartPanel, "TOPLEFT", 10, -10):SetText("Attune chart")

    local toggleRow = CreateFrame("Frame", nil, chartPanel)
    toggleRow:SetHeight(22)
    toggleRow:SetPoint("TOPRIGHT", chartPanel, "TOPRIGHT", -10, -10)
    toggleRow:SetWidth(420)

    local metricBtns = {}
    local bx = 0
    for _, met in ipairs(METRICS) do
        local b = CreateClickPanel(toggleRow, 72, 22, "TOPLEFT", toggleRow, "TOPLEFT", bx, 0, met.label, function()
            dash.metricKey = met.key
            RefreshMetricToggleColors()
            RefreshChart()
        end)
        metricBtns[met.key] = b
        bx = bx + 76
    end

    local modePlot = CreateClickPanel(toggleRow, 56, 22, "TOPLEFT", toggleRow, "TOPLEFT", bx + 8, 0, "Plot", function()
        dash.chartMode = "plot"
        RefreshModeToggleColors()
        RefreshChart()
    end)
    local modeBars = CreateClickPanel(toggleRow, 56, 22, "LEFT", modePlot, "RIGHT", 6, 0, "Bars", function()
        dash.chartMode = "bars"
        RefreshModeToggleColors()
        RefreshChart()
    end)

    local chartSubtitle = CreateText(chartPanel, "GameFontNormalSmall", "TOPLEFT", chartPanel, "TOPLEFT", 10, -34, 680, "LEFT")

    local plotFrame = CreateFrame("Frame", nil, chartPanel)
    plotFrame:SetPoint("TOPLEFT", chartPanel, "TOPLEFT", 10, -56)
    plotFrame:SetPoint("TOPRIGHT", chartPanel, "TOPRIGHT", -10, -56)
    plotFrame:SetHeight(252)

    local band = plotFrame:CreateTexture(nil, "OVERLAY")
    band:SetTexture(LINE_TEX)
    band:Hide()

    local hitFrame = CreateFrame("Frame", nil, plotFrame)
    hitFrame:SetAllPoints(plotFrame)
    hitFrame:EnableMouse(false)

    local chartFooter = CreateText(chartPanel, "GameFontNormalSmall", "BOTTOMLEFT", chartPanel, "BOTTOMLEFT", 12, 42, 680, "LEFT")

    local listToggle = CreateFrame("CheckButton", nil, chartPanel, "UICheckButtonTemplate")
    listToggle:SetPoint("BOTTOMLEFT", chartPanel, "BOTTOMLEFT", 10, 10)
    listToggle:SetChecked(false)
    CreateText(listToggle, "GameFontNormalSmall", "LEFT", listToggle, "RIGHT", 4, 0):SetText("List preview (newest first)")

    local scroll = CreateFrame("ScrollFrame", "AttuneHelperHistoryListScroll", chartPanel, "UIPanelScrollFrameTemplate")
    scroll:SetHeight(88)

    local scrollChild = CreateFrame("Frame", "AttuneHelperHistoryListScrollChild", scroll)
    scrollChild:SetWidth(640)
    scroll:SetScrollChild(scrollChild)

    local listRows = {}
    for i = 1, 40 do
        local fs = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetJustifyH("LEFT")
        fs:SetWidth(620)
        listRows[i] = fs
    end

    listToggle:SetScript("OnClick", function(self)
        dash.listShown = self:GetChecked() == 1
        RefreshChart()
    end)

    scroll:Hide()

    local btnY = 14
    local refreshBtn = CreateClickPanel(root, 120, 26, "BOTTOMLEFT", root, "BOTTOMLEFT", 14, btnY, "Refresh", function()
        AH.RefreshAttuneHistoryDashboard()
    end)
    local clearBtn = CreateClickPanel(root, 160, 26, "LEFT", refreshBtn, "RIGHT", 12, 0, "Clear History", function()
        if AH.ClearDailyAttuneHistory then
            AH.ClearDailyAttuneHistory()
        end
        AH.RefreshAttuneHistoryDashboard()
    end)
    CreateClickPanel(root, 210, 26, "LEFT", clearBtn, "RIGHT", 12, 0, "Dump History to Chat", function()
        local entries = AH.GetDailyAttuneHistory and AH.GetDailyAttuneHistory() or {}
        print("|cff00ff00[AttuneHelper]|r Daily Attune History:")
        if #entries == 0 then
            print("  (no history entries)")
            return
        end
        for i = 1, #entries do
            local entry = entries[i]
            print(string.format("  %s | A:%d TF:%d WF:%d LF:%d", tostring(entry.date),
                tonumber(entry.account) or 0, tonumber(entry.titanforged) or 0,
                tonumber(entry.warforged) or 0, tonumber(entry.lightforged) or 0))
        end
    end)

    dash = {
        chartPanel = chartPanel,
        root = root,
        snapHeader = snapHeader,
        snapBadgeRow = snapBadgeRow,
        snapshotDate = snapDate,
        snapAccount = snapAccount,
        snapTF = snapTF,
        snapWF = snapWF,
        snapLF = snapLF,
        chartSubtitle = chartSubtitle,
        chartFooter = chartFooter,
        plotFrame = plotFrame,
        hitFrame = hitFrame,
        band = band,
        linePool = {},
        markerPool = {},
        gridPool = {},
        barPool = {},
        pickStrips = {},
        axisLabels = {},
        metricBtns = metricBtns,
        modePlot = modePlot,
        modeBars = modeBars,
        metricKey = "account",
        chartMode = "plot",
        series = {},
        listShown = false,
        listToggle = listToggle,
        listScroll = scroll,
        listScrollChild = scrollChild,
        listRows = listRows,
    }

    RefreshMetricToggleColors()
    RefreshModeToggleColors()
    AH.RefreshAttuneHistoryDashboard()
end
