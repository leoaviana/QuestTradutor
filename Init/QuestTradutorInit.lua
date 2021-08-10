-- QuestTradutor, Addon para Vanilla (1.12.1), TBC (2.4) e Wrath (3.3.0+)
-- Port por: Leandro Araujo
-- Pagina do Github: https://github.com/leoaviana/QuestTradutor
-- Original Addon: WoWpoPolsku_Quests (wersja: CLASSIC.02) 2019.12.23
-- Opis: AddOn wyświetla przetłumaczone questy w języku polskim.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- Original Addon project page: https://wowpopolsku.pl 

QuestTradutor = CreateFrame("Frame", nil, UIParent);


local _, _, _, version = GetBuildInfo();

if version >= 20000 and version <= 20400 then
   QuestTradutor.target = 2
elseif version >= 30000 and version <= 30300 then
   QuestTradutor.target = 3
else
   QuestTradutor.target = 3
end

QuestTradutor:RegisterEvent("ADDON_LOADED");
QuestTradutor:RegisterEvent("QUEST_LOG_UPDATE");
QuestTradutor:RegisterEvent("QUEST_DETAIL");
QuestTradutor:RegisterEvent("QUEST_PROGRESS");
QuestTradutor:RegisterEvent("QUEST_COMPLETE");
QuestTradutor:RegisterEvent("QUEST_ACCEPTED"); 
QuestTradutor:RegisterEvent("QUEST_GREETING");
QuestTradutor:RegisterEvent("GOSSIP_SHOW"); 

if(QuestTradutor.target == 2) then
   QuestTradutor.G = getfenv()
   QuestTradutor.QuestLogDetailFrame = QuestLogFrame
else
   QuestTradutor.G = _G
   QuestTradutor.QuestLogDetailFrame = QuestLogDetailFrame
end


if(QuestTradutor.target > 2) then
   QuestTradutor.Print = function(...) print(...) end
else
   QuestTradutor.Print = function(arg1) DEFAULT_CHAT_FRAME:AddMessage(arg1); end
end

 
local function c_gossipHelper(...)
   local gn = 0 
   for i=1, select('#', ...), 2 do 
      gn = gn+1
   end 
   return gn
end   

QuestTradutor.SecHookScript = function(f, script, func)
   local prev = f:GetScript(script)
   f:SetScript(script, function(a1,a2,a3,a4,a5,a6,a7,a8,a9)
     if prev then prev(a1,a2,a3,a4,a5,a6,a7,a8,a9) end
     func(a1,a2,a3,a4,a5,a6,a7,a8,a9)
   end)
 end

QuestTradutor.HookSecureFunction = hooksecurefunc

if(QuestTradutor.target < 3) then
   QuestTradutor.GetNumGossipOptions = function()
      return c_gossipHelper(GetGossipOptions())
   end
else
   QuestTradutor.GetNumGossipOptions = GetNumGossipOptions
end
QuestTradutor.GetNumGossipActiveQuests = GetNumGossipActiveQuests
QuestTradutor.GetNumGossipAvailableQuests = GetNumGossipAvailableQuests

QuestTradutor.StringHash = function(self, text) 
   local counter = 1;
   local pomoc = 0;
   local dlug = string.len(text);
   for i = 1, dlug, 3 do 
     counter = math.fmod(counter*8161, 4294967279);  -- 2^32 - 17: Prime!
     pomoc = (string.byte(text,i)*16776193);
     counter = counter + pomoc;
     pomoc = ((string.byte(text,i+1) or (dlug-i+256))*8372226);
     counter = counter + pomoc;
     pomoc = ((string.byte(text,i+2) or (dlug-i+256))*3932164);
     counter = counter + pomoc;
   end
   return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
 end

 QuestTradutor.GetQuestIDFromQuestLog = function(self, questName, questID, QTR_name, QTR_race, QTR_class)
   local q_title = questName
   local q_i
   local quest_ID

   if ( quest_ID == 0 or quest_ID==nil) then 
      if (QuestTranslator_QuestList[q_title]) then
         local q_lists=QuestTranslator_QuestList[q_title];
         q_i=string.find(q_lists, ","); 
         if ( string.find(q_lists, ",")==nil ) then
            -- only 1 questID to this title
               quest_ID=tonumber(q_lists); 
         else 
               local QTR_table=QuestTradutor:splitqinfo(q_lists, ",", -1);
            
               if(QTR_table == nil) then
                  return 0;
               end
               local QTR_multiple = "";
               local QTR_Center=""; 

               SelectQuestLogEntry(questID)

               for ii,vv in ipairs(QTR_table) do 
                  if (QuestTranslator_QuestMatch[tonumber(vv)]) then
                     local origQuestText = GetQuestLogQuestText();
                     local questTxtMatch = QuestTranslator_QuestMatch[tonumber(vv)]; 
                     questTxtMatch = string.gsub(questTxtMatch, '$N$', string.upper(QTR_name));
                     questTxtMatch = string.gsub(questTxtMatch, '$N', QTR_name);
                     questTxtMatch = string.gsub(questTxtMatch, '$B', '\n');
                     questTxtMatch = string.gsub(questTxtMatch, '$R', QTR_race);
                     questTxtMatch = string.gsub(questTxtMatch, '$C', QTR_class); 
                     questTxtMatch = string.gsub(questTxtMatch, '$b$', string.upper(QTR_name));
                     questTxtMatch = string.gsub(questTxtMatch, '$n', QTR_name);
                     questTxtMatch = string.gsub(questTxtMatch, '$b', '\n');
                     questTxtMatch = string.gsub(questTxtMatch, '$r', QTR_race);
                     questTxtMatch = string.gsub(questTxtMatch, '$c', QTR_class); 
                      
                     if(string.find(origQuestText, questTxtMatch)) then 
                        if (QTR_Center=="") then
                            QTR_Center=vv;
                        else
                            QTR_multiple = QTR_multiple .. ", " .. vv;
                        end 
                     end
                  end 
               end
               if ( string.len(QTR_Center)>0 ) then
                  quest_ID=tonumber(QTR_Center);
                  if ( string.len(QTR_multiple)>0 ) then 
                     QTR_multiple = " (" .. string.sub(QTR_multiple, 3) .. ")";
                     -- Essa quest possui duplicatas, sua tradução pode estar incorreta, porem, é garantida a seleção correta da quest no banco
                     -- de dados utilizando o QuestLog (L) (WOTLK apenas.)
                  end
               end
            end
         end
      end 
   return (quest_ID);
 end