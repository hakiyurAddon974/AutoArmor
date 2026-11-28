-- Deliberately simulated WoW APIs. These tests do not validate the live client.
unpack=table.unpack
local frames={}
local methods={}
local function widget(kind,parent,name)
    local o=setmetatable({kind=kind,parent=parent,name=name,scripts={},events={},visible=true,enabled=true,w=100,h=30,alpha=1,scale=1,text=''}, {__index=methods})
    frames[#frames+1]=o
    return o
end
for _,name in ipairs({'SetPoint','ClearAllPoints','SetAllPoints','SetJustifyH','SetJustifyV','SetTextColor','SetColorTexture','SetVertexColor','SetTexCoord','SetFrameStrata','SetClampedToScreen','SetMovable','EnableMouse','RegisterForDrag','SetNormalTexture','SetHighlightTexture','SetPushedTexture','SetDisabledTexture','SetNormalFontObject','SetHighlightFontObject','SetDisabledFontObject','SetFontObject','SetMultiLine','SetAutoFocus','SetMaxLetters','SetFocus','ClearFocus','HighlightText','StartMoving','StopMovingOrSizing','SetOwner','SetHyperlink','AddLine','AddDoubleLine','SetFromAlpha','SetToAlpha','SetDuration','SetOrder','SetSmoothing','SetScrollStep','SetMaxLines','SetWordWrap'}) do methods[name]=function() end end
function methods:SetSize(w,h) self.w=w;self.h=h end
function methods:SetWidth(w) self.w=w end
function methods:SetHeight(h) self.h=h end
function methods:GetWidth() return self.w end
function methods:GetHeight() return self.h end
function methods:SetFrameLevel(value) self.frameLevel=value end
function methods:GetFrameLevel() return self.frameLevel or (self.parent and self.parent:GetFrameLevel()+1) or 0 end
function methods:GetFrameStrata() return 'MEDIUM' end
function methods:RegisterForClicks() end
function methods:GetEffectiveScale() return self.scale end
function methods:GetCenter() return 900,500 end
function methods:IsMouseOver() return false end
function methods:SetScale(v) self.scale=v end
function methods:SetAlpha(v) self.alpha=v end
function methods:SetTexture(v) self.texture=v end
function methods:SetText(v) self.text=v;if self.font then self.font.text=v end end
function methods:GetText() return self.text end
function methods:GetName() return self.name end
function methods:SetFontString(v) self.font=v end
function methods:GetFontString() return self.font end
function methods:SetChecked(v) self.checked=v end
function methods:GetChecked() return self.checked end
function methods:SetEnabled(v) if self.enabled~=v then self.enabled=v;local f=self.scripts[v and 'OnEnable' or 'OnDisable'];if f then f(self) end end end
function methods:IsEnabled() return self.enabled end
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:HookScript(k,v) local old=self.scripts[k];self.scripts[k]=function(...) if old then old(...) end;v(...) end end
function methods:GetScript(k) return self.scripts[k] end
function methods:Show() local old=self.visible;self.visible=true;if not old and self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:Hide() local old=self.visible;self.visible=false;if old and self.scripts.OnHide then self.scripts.OnHide(self) end end
function methods:SetShown(v) if v then self:Show() else self:Hide() end end
function methods:IsShown() return self.visible end
function methods:SetScrollChild(v) self.child=v end
function methods:RegisterEvent(v) self.events[v]=true end
function methods:UnregisterAllEvents() self.events={} end
function methods:CreateTexture(_,layer) local t=widget('Texture',self);t.layer=layer;return t end
function methods:CreateFontString() return widget('FontString',self) end
function methods:CreateAnimationGroup() return widget('AnimationGroup',self) end
function methods:CreateAnimation() return widget('Animation',self) end
function methods:Play() self.playing=true end
function methods:Stop() self.playing=false end
function CreateFrame(kind,name,parent,template)
    local f=widget(kind,parent,name)
    if name then _G[name]=f end
    if template=='BasicFrameTemplateWithInset' then f.TitleText=widget('FontString',f) end
    return f
end
UIParent=widget('Frame');UIParent:SetSize(1920,1080)
GameTooltip=widget('Tooltip');UISpecialFrames={}
wipe=function(t) for k in pairs(t) do t[k]=nil end end
time=function() return 12345 end
date=os.date
local clock,timers=0,{}
GetTime=function() return clock end
C_Timer={After=function(delay,callback) timers[#timers+1]={at=clock+delay,fn=callback} end}
local function drain()
    local guard=0
    while #timers>0 do
        table.sort(timers,function(a,b) return a.at<b.at end)
        local job=table.remove(timers,1);clock=job.at;job.fn();guard=guard+1;assert(guard<20000,'unbounded timers')
    end
end
local function event(name,...)
    for _,f in ipairs(frames) do if f.events[name] and f.scripts.OnEvent then f.scripts.OnEvent(f,name,...) end end
end
local class,level,combat='MAGE',60,false
UnitClass=function() return class,class end
UnitLevel=function() return level end
UnitName=function() return 'TestCharacter' end
GetNormalizedRealmName=function() return 'TestRealm' end
GetBuildInfo=function() return '1.16.1','test',nil,16001 end
InCombatLockdown=function() return combat end
UnitAffectingCombat=function() return combat end
IsPlayerSpell=function() return true end
local defs,bags,worn={},{},{}
local cursor,origin,refused=nil,nil,{}
NUM_BAG_SLOTS=4
local function data(link) return defs[link] end
local function make(id,loc,stats,extra)
    local d={id=id,link='item:'..id..':0:0:0:0:0:0:0:60:0',name='Item '..id,loc=loc,stats=stats or {},level=50,minLevel=1,classID=4,subclass=1,tip={'Item '..id},bound=true,unique=false,guid='GUID-'..id}
    for k,v in pairs(extra or {}) do d[k]=v end
    defs[d.link]=d;return d
end
local function bag(d,slot) bags[slot or (#bags+1)]=d;return d end
local function wear(slot,d) worn[slot]=d;return d end
local function newcopy(d,guid)
    local n={};for k,v in pairs(d) do n[k]=v end;n.guid=guid;return n
end
GetInventoryItemLink=function(_,slot) return worn[slot] and worn[slot].link end
C_Item={
 GetItemInfo=function(link) local d=data(link);if not d or d.infoMissing then return nil end;return d.name,link,3,d.level,d.minLevel,nil,nil,1,d.loc,123,nil,d.classID,d.subclass,d.bindType or 1,nil,d.setID end,
 GetDetailedItemLevelInfo=function(link) return data(link) and data(link).level end,
 GetItemInfoInstant=function(link) if type(link)=='number' then for _,d in pairs(defs) do if d.id==link then return d.id,nil,nil,d.loc,123,d.classID,d.subclass end end end;local d=data(link);return d and d.id end,
 GetItemStats=function(link) local d=data(link);return d and not d.statsMissing and d.stats or nil end,
 GetItemUniquenessByID=function(link) local d=data(link);if not d or d.uniqueUnknown then return nil end;return d.unique,nil,d.uniqueLimit or 1,d.category end,
 IsEquippableItem=function(link) return data(link) and data(link).equippable~=false end,
 RequestLoadItemDataByID=function() end,
}
ItemLocation={CreateFromBagAndSlot=function(_,b,s) return {bag=b,slot=s} end,CreateFromEquipmentSlot=function(_,s) return {slot=s} end}
C_Item.GetItemGUID=function(loc) local d=loc.bag~=nil and bags[loc.slot] or worn[loc.slot];return d and d.guid end
C_Container={
 GetContainerNumSlots=function(b) return b==0 and 40 or 0 end,
 GetContainerItemInfo=function(b,s) local d=b==0 and bags[s];if not d then return nil end;return {hyperlink=d.link,itemID=d.id,stackCount=1,isBound=d.bound,isLocked=d.locked} end,
 GetContainerNumFreeSlots=function(b) local n=0;if b==0 then for s=1,40 do if not bags[s] then n=n+1 end end end;return n,0 end,
 PickupContainerItem=function(b,s) assert(not cursor);cursor=bags[s];bags[s]=nil;origin={bag=b,slot=s} end,
}
PickupInventoryItem=function(s) assert(not cursor);cursor=worn[s];worn[s]=nil;origin={slot=s} end
CursorHasItem=function() return cursor~=nil end
ClearCursor=function() if cursor then if origin.bag~=nil then bags[origin.slot]=cursor else worn[origin.slot]=cursor end end;cursor=nil;origin=nil end
PutItemInBackpack=function() for s=1,40 do if not bags[s] then bags[s]=cursor;cursor=nil;origin=nil;return end end end
EquipCursorItem=function(s)
    if refused[s] or combat then return end
    if cursor.loc=='INVTYPE_2HWEAPON' and worn[17] then for b=1,40 do if not bags[b] then bags[b]=worn[17];worn[17]=nil;break end end end
    worn[s],cursor=cursor,worn[s]
end
local function tip(link)
    local d=data(link);if not d or d.tipMissing then return nil end
    local lines={};for _,text in ipairs(d.tip) do lines[#lines+1]={leftText=text} end;return {lines=lines}
end
C_TooltipInfo={GetHyperlink=tip,GetBagItem=function(b,s) return b==0 and bags[s] and tip(bags[s].link) end,GetInventoryItem=function(_,s) return worn[s] and tip(worn[s].link) end}
StaticPopupDialogs={};local popup
StaticPopup_Show=function(name) popup=StaticPopupDialogs[name] end
local AA={}
for line in io.lines(ADDON_PATH..'/AutoArmor.toc') do if line:match('%.lua$') then assert(loadfile(ADDON_PATH..'/'..line))('AutoArmor',AA) end end
local function detect(tree)
    local ids={MAGE={frost=64,fire=63,arcane=62},ROGUE={combat=260,assassination=259},
        DRUID={feral=103,guardian=104,balance=102,restoration=105},
        HUNTER={marksmanship=254},WARRIOR={arms=71,protection=73},PALADIN={holy=65,retribution=70,protection=66}}
    local id=assert(ids[class] and ids[class][tree],tree)
    C_SpecializationInfo={GetSpecialization=function() return 1 end,GetSpecializationInfo=function() return id end}
end
local function reset(c)
    class=c or 'MAGE';level=60;combat=false;defs={};bags={};worn={};cursor=nil;origin=nil;refused={};timers={};clock=0
    PawnIsReady=nil;PawnCommon=nil;PawnGetItemData=nil;PawnGetSingleValueFromItem=nil;C_Traits=nil;C_ClassTalents=nil;C_SpecializationInfo=nil
    popup=nil;AA.lastAssessment=nil;AA.lastAnalysisError=nil;AA.planTask=nil;AA.scanning=false;AA.settingsRevision=0;AA.dataGeneration=0;AA.window=nil;AA.preview=nil;AA.review=nil;AA.operation=nil;AA.busy=false;AA.lastUndo=nil;AA.lastOutcome=nil;AA.toast=nil;AA.toastPositioning=false;AA.traitSummary=nil
    AutoArmorDB={};AA:LoadDatabase();AA.db.language='fr';AA.db.showNotifications=false
end
local total=0
local function test(name,fn) reset();local ok,why=xpcall(fn,debug.traceback);if not ok then error('FAIL '..name..'\n'..why) end;total=total+1;print('PASS '..name) end
local function eq(a,b) assert(a==b,tostring(a)..' ~= '..tostring(b)) end
local function near(a,b) assert(math.abs(a-b)<.0001,tostring(a)..' ~= '..tostring(b)) end
local function finishAnalysis()
    local guard=0
    while AA.scanning do
        table.sort(timers,function(a,b) return a.at<b.at end)
        local job=assert(table.remove(timers,1),'analysis has no continuation');clock=job.at;job.fn()
        guard=guard+1;assert(guard<20000,'unbounded analysis')
    end
end
local function jobs(offers) local r={};for _,def in ipairs(AA.slots) do if offers[def.slot] then r[#r+1]=offers[def.slot] end end;return r end
local function sword(id,dps,loc) return make(id,loc or 'INVTYPE_WEAPON',{ITEM_MOD_DAMAGE_PER_SECOND_SHORT=dps},{classID=2,subclass=7}) end
test('unknown mage uses class stats, not high ilvl strength',function()
    level=5;wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=5}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_STRENGTH_SHORT=99},{level=200}));local good=bag(make(3,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{level=20}));eq(AA:FindUpgrades()[1].link,good.link)
end)
test('ambiguous hybrid requires role confirmation',function()
    class='PALADIN';bag(make(3,'INVTYPE_HEAD',{ITEM_MOD_STRENGTH_SHORT=10},{subclass=4}));local safe,_,review=AA:FindUpgrades();eq(safe[1],nil);assert(review[1].reason)
end)
test('caster physical DPS cannot beat spell stats',function()
    detect('frost');wear(16,sword(1,200));bag(sword(2,300));local good=bag(make(3,'INVTYPE_WEAPON',{ITEM_MOD_INTELLECT_SHORT=10},{classID=2,subclass=7}));eq(AA:FindUpgrades()[16].link,good.link)
end)
test('Forever feral includes equipped weapon DPS',function()
    class='DRUID';detect('feral');local d=make(1,'INVTYPE_2HWEAPON',{ITEM_MOD_DAMAGE_PER_SECOND_SHORT=500,ITEM_MOD_AGILITY_SHORT=10},{classID=2,subclass=10});near(AA:ScoreData(AA:BuildItem(d.link),16),2025)
end)
test('hunter uses ranged weapon DPS only',function()
    class='HUNTER';detect('marksmanship');local d=sword(1,100);near(AA:ScoreData(AA:BuildItem(d.link),16),0);near(AA:ScoreData(AA:BuildItem(d.link),18),500)
end)
test('missing stats are blocked, no ilvl fallback',function()
    bag(make(1,'INVTYPE_HEAD',{}, {statsMissing=true,level=999}));local offers,missing=AA:FindUpgrades();eq(offers[1],nil);assert(missing>0)
end)
test('missing tooltip is not treated as safe',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=100},{tipMissing=true}));eq(AA:FindUpgrades()[1],nil)
end)
test('static Equip attack power is evaluated, not doubled',function()
    local d=make(1,'INVTYPE_HEAD',{ITEM_MOD_ATTACK_POWER_SHORT=40},{tip={'Equip: Increases attack power by 40.'}});local a=AA:ReadAssessment(AA:BuildItem(d.link));eq(a.stats.AP,40);eq(#a.effects,0)
end)
test('unknown use and proc effects require confirmation',function()
    bag(make(1,'INVTYPE_TRINKET',{ITEM_MOD_INTELLECT_SHORT=100},{tip={'Use: Increases your damage for 20 sec.'}}));local safe,_,review=AA:FindUpgrades();eq(next(safe),nil);assert(next(review))
end)
test('active set threshold loss needs confirmation',function()
    wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=5},{setID=10,tip={'(2) Set: Better spells.'}}));wear(3,make(2,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=5},{setID=10,tip={'(2) Set: Better spells.'}}));bag(make(3,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));local safe,_,review=AA:FindUpgrades();eq(safe[1],nil);assert(review[1].reason:find('ensemble'))
end)
test('set preserved by replacement remains safe',function()
    wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=5},{setID=10,tip={'(2) Set: Better spells.'}}));wear(3,make(2,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=5},{setID=10,tip={'(2) Set: Better spells.'}}));bag(make(3,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{setID=10}));assert(AA:FindUpgrades()[1])
end)
test('paired weapons choose 99 main and 100 off instead of greedy 100 main',function()
    class='ROGUE';detect('combat');wear(16,sword(1,50));wear(17,sword(2,50));bag(sword(3,100));bag(sword(4,99,'INVTYPE_WEAPONMAINHAND'))
    local plan=AA:FindUpgrades();eq(plan[16].item.itemID,4);eq(plan[17].item.itemID,3);eq(plan[16].group,plan[17].group)
end)
test('two copies of a nonunique ring can both be equipped',function()
    local d=bag(make(1,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=10}));bag(newcopy(d,'SECOND'));local plan=AA:FindUpgrades();assert(plan[11] and plan[12]);assert(plan[11].item.key~=plan[12].item.key)
end)
test('unique category limit applies across different IDs',function()
    wear(11,make(1,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=10},{unique=true,category=20}));bag(make(2,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=20},{unique=true,category=20}));local plan=AA:FindUpgrades();assert(plan[11]);eq(plan[12],nil)
end)
test('same link without known uniqueness cannot fill two slots',function()
    local d=bag(make(1,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=10},{uniqueUnknown=true}));bag(newcopy(d,'SECOND'));local plan=AA:FindUpgrades();assert(not(plan[11] and plan[12]))
end)
test('exact variant keeps enchant, ignores display level',function()
    assert(not AA:EquipmentLinksMatch('item:1:100:0:0:0:0:0:0:60','item:1:200:0:0:0:0:0:0:60'))
    assert(AA:EquipmentLinksMatch('item:1:100:0:0:0:0:0:0:60','item:1:100:0:0:0:0:0:0:20'))
end)
test('locks, protected IDs and second-role reserve are respected',function()
    local d=bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));AA.db.locked[1]=true;eq(AA:FindUpgrades()[1],nil);AA.db.locked={};AA.db.protectedItems['1']=true;eq(AA:FindUpgrades()[1],nil);AA.db.protectedItems={};AA.db.reserveItems['1']=true;eq(AA:FindUpgrades()[1],nil)
end)
test('manual hold blocks automatic scan but permits explicit optimization',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));AA.db.manualOverrides['1']=true;eq(AA:FindUpgrades({automatic=true})[1],nil);assert(AA:FindUpgrades()[1])
end)
test('adaptive armor can compare lighter usable equipment',function()
    class='PALADIN';detect('holy');bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));eq(AA:FindUpgrades()[1],nil);AA.db.preferredArmor=false;assert(AA:FindUpgrades()[1])
end)
test('transaction remains busy until observed result',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));AA:EquipSelected(true);finishAnalysis();assert(AA.busy);eq(AA.lastUndo,nil);local op=AA.operation;AA:EquipSelected(true);eq(AA.operation,op);drain();assert(not AA.busy);eq(#AA.db.history,1);eq(#AA.lastOutcome.changes,1)
end)
test('partial rejection records verified changes and honest failure',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));bag(make(2,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=10}));refused[3]=true;AA:EquipSelected(true);drain();eq(#AA.lastOutcome.changes,1);eq(#AA.lastOutcome.failed,1);eq(#AA.db.history[1].changes,1);assert(bags[2]);assert(not AA.busy)
end)
test('total rejection creates no history or undo',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));refused[1]=true;AA:EquipSelected(true);drain();eq(#AA.db.history,0);eq(AA.lastUndo,nil);eq(#AA.lastOutcome.failed,1)
end)
test('undo restores previous variant and original empty slots',function()
    local old=wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=5},{link='item:1:100:0:0:0:0:0:0:60'}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));bag(make(3,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=10}));AA:EquipSelected(true);drain();AA:UndoLast();drain();eq(worn[1].link,old.link);eq(worn[3],nil);eq(AA.lastOutcome.reason,'undo')
end)
test('plan revalidation refuses changed equipment and locks',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));local plan=jobs(AA:FindUpgrades());wear(1,make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=2}));AA:StartEquipmentQueue(plan,'manual');eq(AA.operation,nil);worn={};plan=jobs(AA:FindUpgrades());AA.db.locked[1]=true;AA:StartEquipmentQueue(plan,'manual');eq(AA.operation,nil)
end)
test('bag movement finds same physical item again',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));local plan=jobs(AA:FindUpgrades());bags[10]=bags[1];bags[1]=nil;AA:StartEquipmentQueue(plan,'manual');drain();assert(worn[1]);eq(#AA.lastOutcome.failed,0)
end)
test('combat and occupied cursor prevent equipment calls',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));combat=true;AA:EquipSelected(true);eq(AA.operation,nil);combat=false;C_Container.PickupContainerItem(0,1);AA:EquipSelected(true);eq(AA.operation,nil);assert(cursor)
end)
test('history restore of unloaded old item never clears a slot',function()
    local old=make(1,'INVTYPE_HEAD',{}, {infoMissing=true});wear(1,make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=5}));AA.db.history={{changes={{slot=1,before=old.link}}}};AA:RestoreHistoryEntry(1,1);eq(AA.operation,nil);eq(worn[1].id,2)
end)
test('Forever talent dominance detected, staged edits withheld',function()
    C_ClassTalents={GetActiveConfigID=function() return 1 end};C_Traits={GetConfigInfo=function() return {treeIDs={1}} end,GetGroupDisplayInfoByTreeID=function() return {{displayName='Frost',groupID=1},{displayName='Fire',groupID=2}} end,GetGroupCurrencyInfo=function(_,ids) return {{currencyInfos={{spent=ids[1]==1 and 20 or 5}}}} end,GetStagedChanges=function() return {},{},{} end};eq(AA:GetScoringContext().id,'frost');C_Traits.GetStagedChanges=function() return {},{1},{} end;eq(AA:GetScoringContext().id,'general')
end)
test('two-handed setup compares entire pair and needs explicit confirmation',function()
    class='WARRIOR';detect('arms');wear(16,sword(1,50));wear(17,sword(2,50));bag(make(3,'INVTYPE_2HWEAPON',{ITEM_MOD_DAMAGE_PER_SECOND_SHORT=100},{classID=2,subclass=8}));eq(AA:FindUpgrades()[16],nil);AA:ReviewWeaponSetup();finishAnalysis();assert(popup);eq(AA.operation,nil);popup.OnAccept();drain();eq(worn[16].id,3);eq(worn[17],nil);eq(#AA.lastOutcome.failed,0)
end)
test('notification outcome and animation cleanup, reduced motion',function()
    AA.db.showNotifications=true;AA:NotifyProgress(2);assert(AA.toast.title.text:find('cours'));AA.toast.scripts.OnUpdate(AA.toast,.1);assert(AA.toast.alpha<1);AA.toast:Hide();eq(AA.toast.scripts.OnUpdate,nil);AA.db.reduceMotion=true;AA:PreviewToast();AA.toast.scripts.OnUpdate(AA.toast,.1);eq(AA.toast.alpha,1);eq(AA.toast.iconFrame.scale,1);AA:NotifyOutcome({changes={},failed={{}}});eq(AA.toast.title.text,'Équipement inchangé');AA.toast.close.scripts.OnClick();eq(AA.toast.scripts.OnUpdate,nil)
end)
test('UI creates every page and refreshes in FR and EN',function()
    AA:CreateUI();AA.window:Show();for _,page in ipairs({'gear','settings','protection','history','diagnostic'}) do AA:ShowPage(page) end;AA:SetLanguage('en');AA:RefreshUI();AA:OpenTextWindow('Diagnostic AutoArmor',AA:BuildDiagnosticText());AA:SetLanguage('fr');AA:Analyze();AA:RefreshUI()
end)
test('paired partial swap retains undo for a displaced source slot',function()
    class='ROGUE';detect('combat');local oldMain=wear(16,sword(1,100));local oldOff=wear(17,sword(2,50));bag(sword(3,99,'INVTYPE_WEAPONMAINHAND'))
    refused[16]=true;AA:EquipSelected(true);drain();eq(worn[17].id,1);eq(worn[16].id,2);eq(#AA.lastOutcome.changes,2);eq(#AA.lastOutcome.failed,1)
    refused={};AA:UndoLast();drain();eq(worn[16].id,oldMain.id);eq(worn[17].id,oldOff.id)
end)
test('diagnostics use relevant slots rather than unrelated incompatibility',function()
    wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=5}));AA:AnalyzeDiagnostics();finishAnalysis();eq(AA.diagnosticResults[1].reason,'Aucun gain selon les critères actuels')
end)
test('weapon hit proc and timed Equip bonus are never labelled static',function()
    local d=make(1,'INVTYPE_WEAPON',{ITEM_MOD_CRIT_RATING_SHORT=1},{tip={'Chance on hit: Launches a fireball.','Equip: Increases your critical strike chance by 10% for 20 sec.'}})
    eq(#AA:ReadAssessment(AA:BuildItem(d.link)).effects,2)
end)
test('loading counter counts items, not paired permutations',function()
    local d=bag(make(1,'INVTYPE_FINGER',{}, {statsMissing=true}));bag(make(2,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=5}));bag(make(3,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=6}));local _,n=AA:FindUpgrades();eq(n,1)
end)
test('quest gain excludes upgrades already available in bags',function()
    wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=5}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));local reward=make(3,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=12});local offer=AA:EvaluateQuestReward(reward.link);near(offer.gain,2*1.3)
end)
test('reserved equipped item is never replaced and bag BoE is skipped',function()
    wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=1}));AA.db.reserveItems['1']=true;bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));eq(AA:FindUpgrades()[1],nil);AA.db.reserveItems={};bags[1].bindType=2;bags[1].bound=false;eq(AA:FindUpgrades()[1],nil)
end)
test('uncommitted proposal does not execute until popup acceptance',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{tip={'Use: Unmodelled effect.'}}));AA:ConfirmReviewed();finishAnalysis();assert(popup);eq(AA.operation,nil);AA.db.locked[1]=true;popup.OnAccept();eq(AA.operation,nil)
end)
test('preview becomes stale after bags or talents change, without auto-scan',function()
    AA:InstallPreviewInvalidation();bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));AA:Analyze();finishAnalysis();assert(AA.preview);event('BAG_UPDATE_DELAYED');eq(AA.preview,nil);eq(AA.operation,nil);AA:Analyze();event('TRAIT_CONFIG_UPDATED');eq(AA.preview,nil)
end)
test('new UI labels and combined reasons translate in English',function()
    AA.db.language='en';AA:CreateUI();local missing={}
    for _,entry in ipairs(AA._i18nWidgets or {}) do
        if entry.source~='Français' and entry.source:find('[\128-\255]') and AA:Tr(entry.source)==entry.source then missing[#missing+1]=entry.source end
    end
    assert(#missing==0,'missing translations: '..table.concat(missing,' / '))
    eq(AA:Tr('Rôle incertain : vérifier les statistiques · Effet spécial à confirmer'),'Uncertain role: review item stats · Special effect needs confirmation')
    AA:OpenTextWindow('Diagnostic AutoArmor','test');local first=AA.textWindow;AA:OpenTextWindow('Diagnostic AutoArmor','next');eq(first,AA.textWindow)
end)
test('temporarily locked bag item is explained and never picked up',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{locked=true}));AA:AnalyzeDiagnostics();finishAnalysis();eq(AA.diagnosticResults[1].reason,'Objet temporairement verrouillé');AA:EquipSelected(true);eq(worn[1],nil)
end)
test('automatic trigger respects opt-out and manual holds',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));AA.db.autoLevelUp=false;AA:AutoOptimize('level');eq(AA.operation,nil);AA.db.autoLevelUp=true;AA.db.manualOverrides['1']=true;AA:AutoOptimize('level');eq(AA.operation,nil);AA.db.manualOverrides={};AA:AutoOptimize('level');drain();eq(AA.lastOutcome.reason,'level');assert(worn[1])
end)
test('login initializes UI and embedded buttons without equipping',function()
    CharacterFrame=widget('Frame');PaperDollFrame=widget('Frame');ContainerFrameCombinedBags=widget('Frame');BagnonFrameinventory=widget('Frame')
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));event('PLAYER_LOGIN');assert(AA.window and AA.toast);assert(CharacterFrame.AutoArmorActionButton);assert(ContainerFrameCombinedBags.AutoArmorActionButton);assert(BagnonFrameinventory.AutoArmorActionButton);eq(worn[1],nil);eq(AA.operation,nil)
    CharacterFrame.AutoArmorActionButton.scripts.OnClick(nil,'RightButton');eq(AA.window.activeTab,'settings')
end)
test('old settings migrate without losing language protections or toast position',function()
    local saved=AutoArmorDB.characters['TestCharacter-TestRealm']
    saved.language='fr';saved.profile='fire';saved.scoreSource='pawn';saved.pawnScale='old';saved.roleSets={Solo={profile='fire'}}
    saved.playStyle='solo';saved.customWeights={STR=999};saved.statCaps={INT=1}
    saved.locked[1]=true;saved.protectedItems['42']=true;saved.reserveItems['43']=true;saved.toastX=25;saved.toastY=-10
    AutoArmorDB.profile='fire';AA:LoadDatabase()
    for _,key in ipairs({'profile','scoreSource','pawnScale','roleSets','playStyle','customWeights','statCaps'}) do eq(AA.db[key],nil) end
    eq(AutoArmorDB.profile,nil);eq(AA.db.language,'fr');assert(AA.db.locked[1]);assert(AA.db.protectedItems['42']);assert(AA.db.reserveItems['43']);eq(AA.db.toastX,25);eq(AA.db.toastY,-10)
    AA:SetOption('profile','fire');eq(AA.db.profile,nil)
end)
test('automatic talent selection ignores retired profile and external scoring',function()
    class='PALADIN';detect('retribution');AA.db.profile='holy';AA.db.scoreSource='pawn';AA.db.customWeights={INT=999}
    local calls=0;local function external() calls=calls+1;return true end
    PawnIsReady=external;PawnGetItemData=external;PawnGetSingleValueFromItem=external
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_STRENGTH_SHORT=10},{subclass=4}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{subclass=4}))
    eq(AA:GetScoringContext().id,'retribution');eq(AA:FindUpgrades()[1].itemID,1);eq(calls,0)
end)
test('settings contain no profile selectors or external-provider controls',function()
    AA:CreateUI();AA:ShowPage('settings')
    eq(AA.window.profilePicker,nil);eq(AA.window.sourcePicker,nil);eq(AA.window.pawnPicker,nil);eq(AA.window.stylePicker,nil)
    eq(AA.GetPawnScales,nil);eq(AA.SavePlayProfile,nil);eq(AA.LoadPlayProfile,nil);eq(AA.ImportWeights,nil)
    for _,entry in ipairs(AA._i18nWidgets or {}) do assert(not entry.source:lower():find('profil',1,true));assert(not entry.source:lower():find('pawn',1,true)) end
end)
test('notification status badge renders above icon for every result',function()
    AA.db.showNotifications=true;AA:PreviewToast();local f=AA.toast
    eq(f.mark.parent,f.badge);eq(f.statusMark.parent,f.badge);assert(f.badge:GetFrameLevel()>f.iconFrame:GetFrameLevel());assert(f.mark:IsShown());assert(f.badge:IsShown())
    AA:NotifyProgress(1);assert(not f.badge:IsShown());assert(not f.mark:IsShown())
    AA:NotifyOutcome({changes={},failed={{}}});assert(f.badge:IsShown());assert(not f.mark:IsShown());eq(f.statusMark.text,'×')
    AA:ShowToast('partial','Mise à jour partielle','test');eq(f.statusMark.text,'!');assert(f.statusMark:IsShown())
    AA.db.reduceMotion=true;AA:PreviewToast();f.scripts.OnUpdate(f,.1);eq(f.mark.alpha,1);assert(f.badge:GetFrameLevel()>f.iconFrame:GetFrameLevel())
    f:Hide();eq(f.scripts.OnUpdate,nil)
end)
test('language dropdown switches FR and EN and closes cleanly',function()
    AA:CreateUI();AA:ShowPage('settings');local picker=AA.window.languagePicker
    eq(AA.window.languageButtons,nil);assert(picker);eq(picker.text,'Français')
    picker.scripts.OnClick();local menu=picker.menu;assert(menu:IsShown());assert(menu.dismiss:IsShown());eq(#menu.rows,2)
    menu.rows[2].scripts.OnClick();eq(AA.db.language,'en');eq(picker.text,'English');assert(not menu:IsShown());assert(not menu.dismiss:IsShown())
    picker.scripts.OnClick();menu.rows[1].scripts.OnClick();eq(AA.db.language,'fr');eq(picker.text,'Français')
    picker.scripts.OnClick();menu.dismiss.scripts.OnClick();assert(not menu:IsShown());eq(AA.openChoiceMenu,nil)
    picker.scripts.OnClick();AA:ShowPage('gear');assert(not menu:IsShown());assert(not menu.dismiss:IsShown())
end)
test('specialization picker lists only class choices and persists the intention',function()
    class='PALADIN';detect('holy');AA:CreateUI();AA:ShowPage('settings');local picker=AA.window.specializationPicker
    picker.scripts.OnClick();local rows=picker.menu.rows;eq(#rows,4);assert(rows[2].text:find('Vindicte'))
    rows[2].scripts.OnClick();eq(AA.db.specialization,'retribution');eq(AA:GetScoringContext().id,'retribution');eq(AA:GetScoringContext().source,'manual')
    AA:LoadDatabase();eq(AA.db.specialization,'retribution')
    AA:SetOption('specialization','frost');eq(AA.db.specialization,'retribution')
    picker.scripts.OnClick();rows[1].scripts.OnClick();eq(AA.db.specialization,'auto');eq(AA:GetScoringContext().id,'holy')
end)
test('manual specialization changes actual recommendations independently of talents',function()
    class='PALADIN';detect('holy');bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_STRENGTH_SHORT=10},{subclass=4}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{subclass=4}))
    eq(AA:FindUpgrades()[1].itemID,2);AA:SetOption('specialization','retribution');eq(AA:FindUpgrades()[1].itemID,1)
    detect('protection');eq(AA:GetScoringContext().id,'retribution')
    AA:SetOption('specialization','auto');eq(AA:GetScoringContext().id,'protection')
end)
test('shared button style uses solid fill and scale-aware full borders',function()
    AA:CreateUI();local picker=AA.window.languagePicker;eq(#picker.AABorders,4)
    picker:SetScale(.65);picker.scripts.OnSizeChanged()
    for _,entry in ipairs(picker.AABorders) do
        eq(entry.texture.layer,'OVERLAY')
        near((entry.vertical and entry.texture.w or entry.texture.h)*picker:GetEffectiveScale(),2)
    end
    for _,w in ipairs(frames) do if w.parent==picker and w.kind=='Texture' then assert(w.layer~='ARTWORK','half-button shine must not exist') end end
end)
test('only one selector is open and class-invalid saved spec resets safely',function()
    class='PALADIN';AA.db.specialization='frost';AA:LoadDatabase();eq(AA.db.specialization,'auto');AA:CreateUI()
    local lang,spec=AA.window.languagePicker,AA.window.specializationPicker
    lang.scripts.OnClick();spec.scripts.OnClick();assert(not lang.menu:IsShown());assert(not lang.menu.dismiss:IsShown());assert(spec.menu:IsShown())
    AA:SetLanguage('en');assert(not spec.menu:IsShown());eq(AA.openChoiceMenu,nil)
end)
-- Included by regression.lua; uses the same deterministic game fixture.
test('global optimizer finds two individually weaker set pieces',function()
    wear(1,make(100,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));wear(3,make(101,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=10}))
    bag(make(102,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=8},{setID=80,tip={'(2) Set: +10 Intellect'}}))
    bag(make(103,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=8},{setID=80,tip={'(2) Set: +10 Intellect'}}))
    local p=AA:FindUpgrades();eq(p[1].itemID,102);eq(p[3].itemID,103);eq(p[1].groupSize,2);near(p[1].groupGain,7.8)
    AA:StartEquipmentQueue({p[1]},'manual');eq(worn[1].id,100);assert(AA.status:find('entièrement'))
    AA:StartEquipmentQueue(jobs(p),'manual');drain();eq(worn[1].id,102);eq(worn[3].id,103)
end)
test('known set bonus is counted once and can outweigh raw stat loss',function()
    wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{setID=8,tip={'(2) Set: +20 Intellect'}}))
    wear(3,make(2,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=10},{setID=8,tip={'(2) Set: +20 Intellect'}}))
    bag(make(3,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=25}));eq(next((AA:FindUpgrades())),nil)
    bags={};bag(make(4,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=40}));local p,_,r=AA:FindUpgrades();eq(p[1].itemID,4);eq(next(r),nil);near(p[1].groupGain,13)
end)
test('global unique category conflict is solved across distant slots',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=100},{unique=true,category=20}))
    bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=98}))
    bag(make(3,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=99},{unique=true,category=20}))
    local p=AA:FindUpgrades();eq(p[1].itemID,2);eq(p[3].itemID,3)
end)
test('unknown gained set bonus remains a review alternative',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{setID=8,tip={'(2) Set: Summons an unknown ally.'}}))
    bag(make(2,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=10},{setID=8,tip={'(2) Set: Summons an unknown ally.'}}))
    local p,_,r=AA:FindUpgrades();assert(r[1] and r[3]);assert(not(p[1] and p[3]));assert(r[1].requiresReview)
end)
test('set tooltip conflicts never receive an invented value',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10},{setID=8,tip={'(2) Set: +20 Intellect'}}))
    bag(make(2,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=10},{setID=8,tip={'(2) Set: +200 Intellect'}}))
    local p,_,r=AA:FindUpgrades();assert(not(p[1] and p[3]));assert(r[1] and r[3])
end)
test('equal gear does not churn between copies or slots',function()
    wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));eq(next((AA:FindUpgrades())),nil)
end)
test('client rating conversion changes with level without hardcoded caps',function()
    CR_CRIT_MELEE=9;GetCombatRatingBonusForCombatRatingValue=function(_,rating) return rating/(level==20 and 7 or 14) end
    local d=make(1,'INVTYPE_HEAD',{ITEM_MOD_CRIT_RATING_SHORT=14});local item=AA:BuildItem(d.link)
    level=60;local a=AA:ScoreData(item,1);level=20;local b=AA:ScoreData(item,1);near(b,a*2)
    CR_CRIT_MELEE=nil;GetCombatRatingBonusForCombatRatingValue=nil
end)
local function traits(lines,rank)
    C_ClassTalents={GetActiveConfigID=function() return 1 end}
    C_Traits={GetConfigInfo=function() return {treeIDs={1}} end,GetTreeNodes=function() return {11} end,
        GetNodeInfo=function() return {activeEntry={entryID=77,rank=rank or 1}} end,GetStagedChanges=function() return {},{},{} end}
    C_TooltipInfo.GetTraitEntry=function(id,r) eq(id,77);eq(r,rank or 1);local a={};for _,t in ipairs(lines) do a[#a+1]={leftText=t} end;return {lines=a} end
end
test('rank-specific committed talent modifies stat conversion',function()
    class='PALADIN';detect('retribution');traits({'Divine Strength','Increases your total Strength by 10%.'},5)
    near(AA:GetScoringContext().weights.STR,2.75);eq(#AA:GetScoringContext().talentAdjustments,1)
end)
test('manual other specialization never borrows active talent bonuses',function()
    class='PALADIN';detect('retribution');traits({'Divine Strength','Increases your total Strength by 10%.'},5)
    AA.db.specialization='holy';local p=AA:GetScoringContext();eq(p.talentCoverage,'different');eq(#p.talentAdjustments,0)
end)
test('uncommitted talent edits do not affect equipment weights',function()
    class='PALADIN';detect('retribution');traits({'Divine Strength','Increases your total Strength by 10%.'},5)
    C_Traits.GetStagedChanges=function() return {1},{},{} end;near(AA:GetScoringContext().weights.STR,2.5)
end)
test('conditional talent text cannot become a permanent stat multiplier',function()
    class='PALADIN';detect('retribution');traits({'Unknown','Increases your Strength by 50% for 10 seconds after a kill.'})
    near(AA:GetScoringContext().weights.STR,2.5)
end)
test('Forever Mental Dexterity hotfix corrects stale beta text by rank',function()
    class='SHAMAN';AA.db.specialization='enhancement';C_SpecializationInfo={GetSpecialization=function() return 1 end,GetSpecializationInfo=function() return 263 end}
    traits({'Mental Dexterity','Increases your attack power by an amount equal to 150% of your Intellect.'},3)
    near(AA:GetScoringContext().weights.INT,1.3)
end)
test('French permanent effects and set stats are recognized conservatively',function()
    local a=AA:ParseStaticBonus('Augmente les dégâts et les soins produits par les sorts et effets magiques de 12 au maximum.');eq(a.SP,12)
    eq(AA:ParseStaticBonus('+8 Intelligence').INT,8)
    eq(AA:ParseStaticBonus('Increases spell power by 100 for 10 sec.'),nil)
end)
test('on-use duration is explained without making the effect automatic',function()
    local d=bag(make(1,'INVTYPE_TRINKET',{ITEM_MOD_INTELLECT_SHORT=20},{tip={'Use: Increases spell power by 100 for 20 sec. (2 Min Cooldown)'}}))
    local a=AA:ReadAssessment(AA:BuildItem(d.link));eq(a.timedEffects[1].duration,20);eq(a.timedEffects[1].cooldown,120)
    local p,_,r=AA:FindUpgrades();eq(next(p),nil);assert(next(r));assert(AA:ExplainUpgrade(r[13] or r[14]):find('activation non simulée'))
end)
test('owned item comparison never invents a second ring copy',function()
    local d=wear(11,make(1,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=10}));local offer=AA:CompareItem(d.link);eq(offer,nil);eq(worn[12],nil)
end)
test('item comparison considers both weapon hands without equipping',function()
    class='WARRIOR';detect('arms');wear(16,sword(1,50));wear(17,sword(2,50))
    local d=make(3,'INVTYPE_2HWEAPON',{ITEM_MOD_DAMAGE_PER_SECOND_SHORT=100},{classID=2,subclass=8})
    local offer=AA:CompareItem(d.link);assert(offer and offer.groupSize==2);eq(worn[16].id,1);eq(worn[17].id,2)
end)
test('future item suggestions are useful and never auto-reserved',function()
    level=20;bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=20},{minLevel=23}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=20},{minLevel=40}))
    local hints=AA:FindKeepSuggestions();eq(#hints,1);eq(hints[1].item.itemID,1);assert(hints[1].reason:find('23'));eq(next(AA.db.reserveItems),nil);eq(next((AA:FindUpgrades())),nil)
end)
test('alternate specialization hints respect class and protection',function()
    class='PALADIN';detect('retribution');wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_STRENGTH_SHORT=30},{subclass=4}));bag(make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=20},{subclass=4}))
    local hints=AA:FindKeepSuggestions();eq(#hints,1);eq(hints[1].spec.id,'holy');AA.db.protectedItems['2']=true;eq(#AA:FindKeepSuggestions(),0)
end)
test('settings changes invalidate pending confirmation',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=20},{tip={'Use: Unknown.'}}));AA:ConfirmReviewed();finishAnalysis();assert(popup)
    AA:SetOption('scoringMode','ilvl');popup.OnAccept();eq(AA.operation,nil);eq(worn[1],nil)
end)
test('automatic disabled weapons cannot break a grouped plan',function()
    class='WARRIOR';detect('arms');wear(16,sword(1,10));bag(sword(2,20));bag(make(3,'INVTYPE_HEAD',{ITEM_MOD_STRENGTH_SHORT=20},{subclass=4}));AA.db.autoWeapons=false
    local p=AA:FindUpgrades({automatic=true});eq(p[16],nil);eq(p[1].groupSize,1)
end)
test('long analysis yields and cancellation prevents results and equips',function()
    local ticks=0;debugprofilestop=function() ticks=ticks+1;return ticks*4 end
    for i=1,25 do bag(make(i,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=i})) end
    local called=false;AA:StartPlanTask({},function() called=true end);assert(AA.scanning);assert(#timers>0);AA:InvalidatePreview();drain();eq(called,false);eq(AA.preview,nil);eq(worn[11],nil);debugprofilestop=nil
end)
test('combat cancels a running analysis before equipment',function()
    local ticks=0;debugprofilestop=function() ticks=ticks+1;return ticks*4 end
    for i=1,20 do bag(make(i,'INVTYPE_FINGER',{ITEM_MOD_INTELLECT_SHORT=i})) end
    AA:EquipSelected(true);assert(AA.scanning);combat=true;drain();eq(AA.operation,nil);eq(worn[11],nil);assert(not AA.scanning);debugprofilestop=nil
end)
test('three primary tabs and both intended specialization menus work',function()
    AA:CreateUI();local n=0;for _ in pairs(AA.window.nav) do n=n+1 end;eq(n,3)
    AA.window.gearSpecialization.scripts.OnClick();assert(AA.window.gearSpecialization.menu:IsShown());AA:ShowPage('settings');assert(not AA.window.gearSpecialization.menu:IsShown())
    AA:RefreshInventoryPage(true);AA:ShowPage('inventory');AA:SetLanguage('en');AA:SetLanguage('fr')
end)
test('new installs are manual and existing automation choices are preserved',function()
    eq(AA.db.autoQuestRewards,false);eq(AA.db.autoLevelUp,false);AA.db.autoQuestRewards=true;AA.db.autoLevelUp=true;AA:LoadDatabase();eq(AA.db.autoQuestRewards,true);eq(AA.db.autoLevelUp,true)
end)
for _,token in ipairs({'WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','MAGE','WARLOCK','SHAMAN','DRUID'}) do
    test('class specialization matrix: '..token,function()
        class=token;local choices=AA:GetSpecializationChoices();assert(#choices>=3)
        for _,choice in ipairs(choices) do
            AA.db.specialization=choice.id;local context=AA:GetScoringContext();eq(context.id,choice.id)
            local stat=context.role=='TANK' and 'ITEM_MOD_STAMINA_SHORT' or context.role=='HEALER' and 'ITEM_MOD_INTELLECT_SHORT' or (context.weapon=='caster' and 'ITEM_MOD_SPELL_POWER_SHORT' or 'ITEM_MOD_ATTACK_POWER_SHORT')
            bags={};worn={};local good=bag(make(100,'INVTYPE_HEAD',{[stat]=25},{subclass=AA:GetArmorSubclass()}));bag(make(101,'INVTYPE_HEAD',{}, {subclass=AA:GetArmorSubclass(),level=999}))
            local plan=AA:FindUpgrades();assert(plan[1],choice.id);eq(plan[1].itemID,good.id)
        end
    end)
end

test('small global searches agree with exhaustive enumeration',function()
    math.randomseed(10001)
    for sample=1,40 do
        bags={};worn={};defs={}
        local slots={1,3,5,10};local locs={'INVTYPE_HEAD','INVTYPE_SHOULDER','INVTYPE_CHEST','INVTYPE_HAND'};local pool={}
        for i,slot in ipairs(slots) do
            pool[i]={make(i*100,'INVTYPE_'..({'HEAD','SHOULDER','CHEST','HAND'})[i],{ITEM_MOD_INTELLECT_SHORT=math.random(1,10)})};wear(slot,pool[i][1])
            for j=1,2 do
                local set=math.random(0,2);local cat=math.random(1,4)==1 and 60 or nil
                local item=bag(make(i*100+j,locs[i],{ITEM_MOD_INTELLECT_SHORT=math.random(1,15)},{setID=set>0 and set or nil,unique=cat~=nil,category=cat,tip=set>0 and {'(2) Set: +12 Intellect'} or {'No effect'}}));pool[i][#pool[i]+1]=item
            end
        end
        local baseline=0;for _,d in pairs(worn) do baseline=baseline+d.stats.ITEM_MOD_INTELLECT_SHORT end
        local best=baseline
        for _,a in ipairs(pool[1]) do for _,b in ipairs(pool[2]) do for _,c in ipairs(pool[3]) do for _,d in ipairs(pool[4]) do
            local total,sets,unique=0,{},0
            for _,item in ipairs({a,b,c,d}) do total=total+item.stats.ITEM_MOD_INTELLECT_SHORT;if item.setID then sets[item.setID]=(sets[item.setID] or 0)+1 end;if item.category then unique=unique+1 end end
            if unique<=1 then for _,n in pairs(sets) do if n>=2 then total=total+12 end end;best=math.max(best,total) end
        end end end end
        AA:FindUpgrades();near(AA.lastAssessment.gain,(best-baseline)*1.3)
    end
end)
test('200-item scan completes cooperatively with bounded frontier',function()
    local originalSlots=C_Container.GetContainerNumSlots
    C_Container.GetContainerNumSlots=function(b) return b==0 and 200 or 0 end
    local locs={'INVTYPE_HEAD','INVTYPE_SHOULDER','INVTYPE_CHEST','INVTYPE_HAND','INVTYPE_FINGER','INVTYPE_TRINKET','INVTYPE_LEGS','INVTYPE_FEET'}
    for i=1,200 do bag(make(i,locs[(i-1)%8+1],{ITEM_MOD_INTELLECT_SHORT=(i*17)%45+1})) end
    debugprofilestop=function() return os.clock()*1000 end
    local finished=false;local start=os.clock()
    AA:StartPlanTask({},function(p) finished=true;assert(next(p)) end);assert(AA.scanning);drain();assert(finished)
    assert(AA.lastAssessment.slices>1);assert(AA.lastAssessment.bounded)
    print(string.format('BENCH: 200 items / %d evaluations / %d slices / max %.2f ms / CPU %.3f s (mock client)',AA.lastAssessment.evaluated,AA.lastAssessment.slices,AA.lastAssessment.maxSliceMs,os.clock()-start))
    C_Container.GetContainerNumSlots=originalSlots;debugprofilestop=nil
end)
test('quest panel explains already-owned better rewards and pending effects',function()
    QuestFrame=widget('Frame');GetNumQuestChoices=function() return 2 end
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=30}))
    local a=make(2,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10});local b=make(3,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=20})
    GetQuestItemLink=function(_,i) return i==1 and a.link or b.link end
    AA:ShowQuestRecommendation();drain();assert(AA.questPanel.message.text:find('déjà disponibles'));eq(worn[1],nil)
    b.tip={'Use: Unknown effect.'};b.stats.ITEM_MOD_INTELLECT_SHORT=100
    AA:ShowQuestRecommendation();drain();assert(AA.questPanel.message.text:find('incertain'));eq(worn[1],nil)
    GetNumQuestChoices=nil;GetQuestItemLink=nil;QuestFrame=nil
end)
test('item comparison shortcut is optional and requires both modifiers',function()
    local originalHook=hooksecurefunc;local hook;HandleModifiedItemClick=function() end
    hooksecurefunc=function(name,fn) if name=='HandleModifiedItemClick' then hook=fn end end
    AA.comparisonHooked=nil;AA:InstallComparisonShortcut();assert(hook)
    local item=bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=20}));local ctrl=false
    IsAltKeyDown=function() return true end;IsControlKeyDown=function() return ctrl end
    AA.textWindow=nil;hook(item.link);eq(AA.textWindow,nil);ctrl=true;hook(item.link);assert(AA.textWindow);AA.textWindow:Hide()
    AA.db.itemCompare=false;hook(item.link);assert(not AA.textWindow:IsShown());eq(worn[1],nil)
    hooksecurefunc=originalHook;HandleModifiedItemClick=nil;IsAltKeyDown=nil;IsControlKeyDown=nil
end)

test('planned set comparison retains the complete combination explanation',function()
    wear(1,make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=10}));wear(3,make(2,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=10}))
    local head=bag(make(3,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=8},{setID=80,tip={'(2) Set: +10 Intellect'}}))
    bag(make(4,'INVTYPE_SHOULDER',{ITEM_MOD_INTELLECT_SHORT=8},{setID=80,tip={'(2) Set: +10 Intellect'}}))
    AA:CreateUI();AA:Analyze();drain();eq(AA:CompareItem(head.link),nil)
    AA.window.rows[1].offerTip.scripts.OnClick()
    assert(AA.textWindow.edit.text:find('Item 4'));assert(AA.textWindow.edit.text:find('2 changements'))
    eq(worn[1].id,1);eq(worn[3].id,2)
end)
test('primary button rescans when no proposed changes are selected',function()
    bag(make(1,'INVTYPE_HEAD',{ITEM_MOD_INTELLECT_SHORT=20}));AA:CreateUI();AA:Analyze();drain()
    AA.selected={};AA:RefreshUI();eq(AA.window.primaryButton.text,'Analyser mes sacs')
    AA.window.primaryButton.scripts.OnClick();drain();assert(AA.selected[1]);eq(worn[1],nil)
end)
test('primary stat amplification and conversion are independent of talent enumeration order',function()
    class='PALADIN';detect('holy')
    local a={name='Amplification',lines={'Increases your total Intellect by 10%.'}}
    local b={name='Conversion',lines={'Increases your spell damage by an amount equal to 20% of your Intellect.'}}
    local original=AA.ReadCommittedTalents
    AA.ReadCommittedTalents=function() return {a,b},'client' end
    local first={weights={INT=2,SP=3}};AA:ApplyTalentWeights(first)
    AA.ReadCommittedTalents=function() return {b,a},'client' end
    local second={weights={INT=2,SP=3}};AA:ApplyTalentWeights(second)
    AA.ReadCommittedTalents=original
    near(first.weights.INT,2.86);near(second.weights.INT,first.weights.INT)
end)
test('200 pieces from 50 sets preserve the best complete set',function()
    local original=C_Container.GetContainerNumSlots
    C_Container.GetContainerNumSlots=function(b) return b==0 and 200 or 0 end
    local locs={'INVTYPE_HEAD','INVTYPE_SHOULDER','INVTYPE_CHEST','INVTYPE_LEGS'}
    for set=1,50 do for i,loc in ipairs(locs) do
        bag(make(set*10+i,loc,{ITEM_MOD_INTELLECT_SHORT=set==50 and 15 or 10},{setID=set,tip={'(4) Set: +20 Intellect'}}))
    end end
    debugprofilestop=function() return os.clock()*1000 end
    local start=os.clock();local result
    AA:StartPlanTask({},function(p) result=p end);drain()
    eq(result[1].itemID,501);eq(result[3].itemID,502);eq(result[5].itemID,503);eq(result[7].itemID,504)
    assert(AA.lastAssessment.slices>1);eq(AA.operation,nil)
    print(string.format('BENCH: 200 set pieces / 50 sets / %d slices / max %.2f ms / CPU %.3f s (mock client)',AA.lastAssessment.slices,AA.lastAssessment.maxSliceMs,os.clock()-start))
    C_Container.GetContainerNumSlots=original;debugprofilestop=nil
end)

print(string.format('RESULT: %d regression scenarios passed (simulated APIs, Lua 5.4)',total))
