local _, AA = ...
local palette={success={.42,.88,.64},partial={1,.76,.36},failed={.95,.49,.40},info={.82,.68,.42},progress={.68,.78,.96},review={1,.76,.36}}
local function texture(parent,w,h,x,y)
    local t=parent:CreateTexture(nil,'ARTWORK');t:SetSize(w,h);t:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y);return t
end
function AA:RestoreToastPosition()
    if not self.toast or not self.db then return end
    self.toast:ClearAllPoints()
    if type(self.db.toastX)=='number' and type(self.db.toastY)=='number' then self.toast:SetPoint('CENTER',UIParent,'CENTER',self.db.toastX,self.db.toastY)
    else self.toast:SetPoint('TOP',UIParent,'TOP',0,-140) end
end
function AA:SaveToastPosition()
    if not self.toast then return end
    local x,y=self.toast:GetCenter();local px,py=UIParent:GetCenter()
    if x and px then self.db.toastX=math.floor(x-px+.5);self.db.toastY=math.floor(y-py+.5) end
end
function AA:CreateToast()
    if self.toast then return end
    local f=CreateFrame('Frame',nil,UIParent);self.toast=f
    f:SetSize(390,108);f:SetFrameStrata('DIALOG');f:SetFrameLevel(120);f:SetClampedToScreen(true)
    f:SetMovable(true);f:EnableMouse(true);f:RegisterForDrag('LeftButton')
    local bg=f:CreateTexture(nil,'BACKGROUND');bg:SetAllPoints();bg:SetColorTexture(.075,.067,.055,.97)
    f.accent=texture(f,3,108,0,0)
    local edge=texture(f,390,1,0,0);edge:SetColorTexture(.60,.46,.27,.9)
    f.iconFrame=CreateFrame('Frame',nil,f);f.iconFrame:SetSize(38,38);f.iconFrame:SetPoint('TOPLEFT',f,'TOPLEFT',16,-18)
    f.iconFrame:SetFrameLevel(f:GetFrameLevel()+1)
    f.icon=f.iconFrame:CreateTexture(nil,'ARTWORK');f.icon:SetAllPoints();f.icon:SetTexture('Interface/AddOns/AutoArmor/Textures/AutoArmorListIcon');f.icon:SetTexCoord(.05,.95,.05,.95)
    -- A draw layer on the toast cannot cover the icon's child frame. Put the
    -- status badge in its own higher-level frame, outside the animated scale.
    f.badge=CreateFrame('Frame',nil,f);f.badge:SetSize(22,22);f.badge:SetPoint('TOPLEFT',f,'TOPLEFT',43,-39)
    f.badge:SetFrameLevel(f.iconFrame:GetFrameLevel()+2);f.badge:EnableMouse(false)
    local badgeBackground=f.badge:CreateTexture(nil,'BACKGROUND');badgeBackground:SetAllPoints();badgeBackground:SetColorTexture(.045,.04,.035,.97)
    f.mark=f.badge:CreateTexture(nil,'OVERLAY');f.mark:SetAllPoints()
    f.mark:SetTexture('Interface/Buttons/UI-CheckBox-Check')
    f.statusMark=f.badge:CreateFontString(nil,'OVERLAY','GameFontNormalLarge');f.statusMark:SetPoint('CENTER',f.badge,'CENTER',0,0)
    f.title=f:CreateFontString(nil,'OVERLAY','GameFontNormal');f.title:SetPoint('TOPLEFT',f,'TOPLEFT',68,-14);f.title:SetWidth(287);f.title:SetJustifyH('LEFT')
    f.message=f:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');f.message:SetPoint('TOPLEFT',f,'TOPLEFT',68,-36);f.message:SetWidth(295);f.message:SetHeight(34);f.message:SetJustifyH('LEFT');f.message:SetJustifyV('TOP')
    f.detail=f:CreateFontString(nil,'OVERLAY','GameFontDisableSmall');f.detail:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',17,15);f.detail:SetWidth(255);f.detail:SetJustifyH('LEFT')
    f.bar=texture(f,390,2,0,-106)
    f.undo=CreateFrame('Button',nil,f);f.undo:SetSize(90,24);f.undo:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-12,8)
    local label=f.undo:CreateFontString(nil,'OVERLAY','GameFontNormalSmall');label:SetAllPoints();f.undo:SetFontString(label);f.undo:SetText(self:Tr('Annuler'))
    f.undo:SetScript('OnClick',function() AA:UndoLast() end)
    f.close=CreateFrame('Button',nil,f);f.close:SetSize(22,22);f.close:SetPoint('TOPRIGHT',f,'TOPRIGHT',-3,-3)
    local cross=f.close:CreateFontString(nil,'OVERLAY','GameFontNormal');cross:SetAllPoints();cross:SetText('×')
    f.close:SetScript('OnClick',function() if AA.toastPositioning then AA:EndToastPositioning() else f:Hide() end end)
    f:SetScript('OnHide',function(self) self:SetScript('OnUpdate',nil);self:SetAlpha(1);self.iconFrame:SetScale(1) end)
    f:SetScript('OnDragStart',function(self) if AA.toastPositioning then self:StartMoving() end end)
    f:SetScript('OnDragStop',function(self) self:StopMovingOrSizing();AA:SaveToastPosition() end)
    f:SetScript('OnMouseUp',function(_,button) if button=='RightButton' and AA.toastPositioning then AA:EndToastPositioning() end end)
    self:RestoreToastPosition();f:Hide()
end
function AA:ShowToast(kind,title,message,icon,detail,undo)
    if not self.db or not self.db.showNotifications or self.toastPositioning then return end
    if not self.toast then self:CreateToast() end
    local f=self.toast;local color=palette[kind] or palette.info
    f:SetScript('OnUpdate',nil);f:SetAlpha(1);f.iconFrame:SetScale(1)
    f.title:SetText(self:Tr(title));f.title:SetTextColor(color[1],color[2],color[3])
    self.toastRaw=message;f.message:SetText(self:Tr(message));f.message:SetTextColor(.91,.89,.83)
    f.detail:SetText(self:Tr(detail or 'AutoArmor'));f.accent:SetColorTexture(color[1],color[2],color[3],1)
    f.bar:SetColorTexture(color[1],color[2],color[3],.8);f.bar:SetWidth(390)
    f.icon:SetTexture(icon or 'Interface/AddOns/AutoArmor/Textures/AutoArmorListIcon')
    f.badge:SetShown(kind~='progress')
    f.mark:SetVertexColor(color[1],color[2],color[3]);f.mark:SetShown(kind=='success')
    f.statusMark:SetText(kind=='failed' and '×' or ((kind=='partial' or kind=='review') and '!' or '–'))
    f.statusMark:SetTextColor(color[1],color[2],color[3]);f.statusMark:SetShown(kind~='success' and kind~='progress')
    f.undo:SetShown(not not (undo and self.lastUndo~=nil));f.undo:SetText(self:Tr('Annuler'));f.undo:SetEnabled(not self.busy)
    f:Show()
    local time=0;local held=0;local duration=kind=='progress' and 3 or 5.5
    -- Animation runs only while this toast is visible; no global permanent ticker.
    f:SetScript('OnUpdate',function(self,elapsed)
        time=time+elapsed
        if self.IsMouseOver and self:IsMouseOver() and time>.25 and held<15 then held=held+elapsed else duration=duration-elapsed end
        local reduce=AA.db.reduceMotion
        local alpha=reduce and 1 or math.min(1,time/.18,math.max(0,duration/.35))
        self:SetAlpha(alpha)
        if not reduce then
            local t=math.min(1,time/.28);local ease=1-(1-t)^3
            self.iconFrame:SetScale(.86+.14*ease)
            if kind=='progress' then self.icon:SetAlpha(.65+.35*math.sin(time*4)^2) else self.icon:SetAlpha(1) end
            self.mark:SetAlpha(math.min(1,math.max(0,(time-.12)/.18)))
            self.statusMark:SetAlpha(math.min(1,math.max(0,(time-.12)/.18)))
        else self.iconFrame:SetScale(1);self.icon:SetAlpha(1);self.mark:SetAlpha(1);self.statusMark:SetAlpha(1) end
        self.bar:SetWidth(math.max(1,390*math.min(1,duration/(kind=='progress' and 3 or 5.5))))
        if duration<=0 then self:Hide() end
    end)
end
function AA:NotifyProgress(count)
    self:ShowToast('progress','Équipement en cours',self:TF('Vérification de %d emplacement(s)…',count),nil,'En attente de la confirmation du jeu')
end
function AA:NotifyOutcome(outcome)
    local changes=outcome.changes or {};local failures=outcome.failed or {}
    local first=changes[1];local item=first and first.after and self:BuildItem(first.after)
    if outcome.empty then self:ShowToast('info','Équipement conservé','Aucune amélioration évaluée dans tes sacs.',nil,'Ouvre le diagnostic pour voir les explications');return end
    if outcome.review then self:ShowToast('review','À confirmer','Certains objets demandent de vérifier les effets ou les statistiques.',nil,'Ouvre Équipement pour voir les explications');return end
    local kind=#changes==0 and 'failed' or (#failures>0 and 'partial' or 'success')
    local title=kind=='success' and (outcome.reason=='undo' and 'Équipement restauré' or 'Équipement mis à jour') or (kind=='partial' and 'Mise à jour partielle' or 'Équipement inchangé')
    local message=item and item.name or (#changes>0 and self:TF('%d emplacement(s) mis à jour.',#changes) or 'Le jeu n’a confirmé aucun changement.')
    if item and #changes>1 then message=message..self:TF(' et %d autre(s).',#changes-1) end
    local detail=#failures>0 and self:TF('%d objet(s) non confirmé(s) · ouvre le diagnostic',#failures) or 'Changements confirmés par le jeu'
    self:ShowToast(kind,title,message,item and item.icon,detail,#changes>0)
end
function AA:Notify(message) self:ShowToast('info','AutoArmor',message) end
function AA:PreviewToast()
    self:ShowToast('success','Aperçu de notification','Voici l’animation de confirmation.',nil,'Aperçu uniquement · aucun objet modifié',false)
end
function AA:BeginToastPositioning()
    if not self.toast then self:CreateToast() end
    self.toastPositioning=true
    local f=self.toast;f:SetScript('OnUpdate',nil);f:SetAlpha(1);f.iconFrame:SetScale(1)
    f.title:SetText('AutoArmor');f.message:SetText(self:Tr('Glisse-moi où tu veux. Clic droit pour terminer.'));f.detail:SetText(self:Tr('Position de la notification'));f.undo:Hide();f:Show()
    if self.RefreshUI then self:RefreshUI() end
end
function AA:EndToastPositioning()
    self:SaveToastPosition();self.toastPositioning=false;if self.toast then self.toast:Hide() end
    if self.RefreshUI then self:RefreshUI() end
end
function AA:ResetToastPosition()
    if self.toastPositioning then self:EndToastPositioning() end
    self.db.toastX,self.db.toastY=nil,nil;self:RestoreToastPosition()
end
