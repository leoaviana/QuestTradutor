-- QuestTradutor, Addon para Vanilla (1.12.1), TBC (2.4) e Wrath (3.3.0+)
-- Port por: Leandro Araujo
-- Pagina do Github: https://github.com/leoaviana/QuestTradutor
-- Original Addon: WoWpoPolsku_Quests (wersja: CLASSIC.02) 2019.12.23
-- Opis: AddOn wyświetla przetłumaczone questy w języku polskim.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- Original Addon project page: https://wowpopolsku.pl 

local QTR_version = GetAddOnMetadata("QuestTradutor", "Version");
 
QuestTradutor:SetScript("OnEvent", function() QuestTradutor:OnEvent(this, event, name, arg1,arg2,arg3,arg4,arg5) end);  


local QTR_onDebug = false;      
local QTR_name = UnitName("player");
local QTR_class= UnitClass("player");
local QTR_race = UnitRace("player");
local QTR_sex = UnitSex("player");     -- 1:neutral,  2:męski,  3:żeński 
local QTR_OldQuestCache
local QTR_QuestCache
local QTROptionsFrame
local _G = QuestTradutor.G
local print
local c_hooksecurefunc
local c_HookScript

if(QuestTradutor.target <= 2) then
   if(QuestTradutor.SecHookScript) then
      c_HookScript = QuestTradutor.SecHookScript
   end
   if(QuestTradutor.HookSecureFunction) then
      c_hooksecurefunc = QuestTradutor.HookSecureFunction
   end
end

if(QuestTradutor.Print) then
   print = QuestTradutor.Print 
end


local QTR_flaggedForItemFix = false;
local QTR_flaggedDisableTT = {};
local QTR_MessOrig = {
      details    = "Description", 
      objectives = "Objectives", 
      rewards    = "Rewards", 
      itemchoose1= "You will be able to choose one of these rewards:", 
      itemchoose2= "Choose one of these rewards:", 
      itemreceiv1= "You will also receive:", 
      itemreceiv2= "You receiving the reward:", 
      learnspell = "Learn Spell:", 
      reqmoney   = "Required Money:", 
      reqitems   = "Required items:", 
      experience = "Experience:", 
      currquests = "Current Quests", 
      avaiquests = "Available Quests", };

      local QTR_Reklama = { 
         ON = "Ativar a divulgação do addon no chat.",
         PERIOD = "Tempo entre sucessivas divulgações:",
         TEXT1 = "A quest %s foi traduzida e aceita utilizando o addon QuestTradutor (https://tiny.cc/questtradutor)",
         TEXT2 = "QuestTradutor - Um AddOn que traduz quests, skills e itens (https://tiny.cc/questtradutor)",
         CHANNEL = "Canal utilizado para propagar a mensagem (0 é o /say)",
   }; 

local QTR_GameTooltip = GameTooltip;
local QTR_GameTooltipTextLeft = "GameTooltipTextLeft"
local QTR_GameTooltipTextLeft1 = "GameTooltipTextLeft1"
local QTR_GameTooltipTextRight = "GameTooltipTextRight"
local QTR_GameTooltipMoneyFrame1PrefixText = "GameTooltipMoneyFrame1PrefixText"
local QTR_GameTooltipMoneyFrame2PrefixText = "GameTooltipMoneyFrame1PrefixText"


local QTR_quest_EN = {
      id = 0,
      title = "",
      details = "",
      objectives = "",
      progress = "",
      completion = "",
      itemchoose = "",
      itemreceive = "", };      
local QTR_quest_LG = {
      id = 0,
      title = "",
      details = "", 
      objectives = "", 
      progress = "", 
      completion = "", 
      itemchoose = "",
      itemreceive = "", };       
local last_time = GetTime();
local last_text = 0;
local curr_trans = "1";
local curr_goss = "X";
local QTR_GS_MENUS = {};
local curr_hash = 0;
local Original_Font1 = "Fonts\\MORPHEUS.ttf";
local Original_Font2 = "Fonts\\FRIZQT__.ttf";
local WT_Font = Original_Font2;
local p_race = {
      ["Blood Elf"] = { M1="Krwawy Elf", D1="krwawego elfa", C1="krwawemu elfowi", B1="krwawego elfa", N1="krwawym elfem", K1="krwawym elfie", W1="Elfo Sangrento", M2="Krwawa Elfka", D2="krwawej elfki", C2="krwawej elfce", B2="krwawą elfkę", N2="krwawą elfką", K2="krwawej elfce", W2="Elfa Sangrenta" }, 
      ["Dark Iron Dwarf"] = { M1="Krasnolud Ciemnego Żelaza", D1="krasnoluda Ciemnego Żelaza", C1="krasnoludowi Ciemnego Żelaza", B1="krasnoluda Ciemnego Żelaza", N1="krasnoludem Ciemnego Żelaza", K1="krasnoludzie Ciemnego Żelaza", W1="Anão Ferro Negro", M2="Krasnoludka Ciemnego Żelaza", D2="krasnoludki Ciemnego Żelaza", C2="krasnoludce Ciemnego Żelaza", B2="krasnoludkę Ciemnego Żelaza", N2="krasnoludką Ciemnego Żelaza", K2="krasnoludce Ciemnego Żelaza", W2="Anã Ferro Negro" },
      ["Draenei"] = { M1="Draenei", D1="draeneia", C1="draeneiowi", B1="draeneia", N1="draeneiem", K1="draeneiu", W1="Draenei", M2="Draeneika", D2="draeneiki", C2="draeneice", B2="draeneikę", N2="draeneiką", K2="draeneice", W2="Draenaia" },
      ["Dwarf"] = { M1="Krasnolud", D1="krasnoluda", C1="krasnoludowi", B1="krasnoluda", N1="krasnoludem", K1="krasnoludzie", W1="Anão", M2="Krasnoludka", D2="krasnoludki", C2="krasnoludce", B2="krasnoludkę", N2="krasnoludką", K2="krasnoludce", W2="Anã" },
      ["Gnome"] = { M1="Gnom", D1="gnoma", C1="gnomowi", B1="gnoma", N1="gnomem", K1="gnomie", W1="Gnomo", M2="Gnomka", D2="gnomki", C2="gnomce", B2="gnomkę", N2="gnomką", K2="gnomce", W2="Gnomida" },
      ["Goblin"] = { M1="Goblin", D1="goblina", C1="goblinowi", B1="goblina", N1="goblinem", K1="goblinie", W1="Goblin", M2="Goblinka", D2="goblinki", C2="goblince", B2="goblinkę", N2="goblinką", K2="goblince", W2="Goblina" },
      ["Highmountain Tauren"] = { M1="Tauren z Wysokiej Góry", D1="taurena z Wysokiej Góry", C1="taurenowi z Wysokiej Góry", B1="taurena z Wysokiej Góry", N1="taurenen z Wysokiej Góry", K1="taurenie z Wysokiej Góry", W1="Highmountain Tauren", M2="Taurenka z Wysokiej Góry", D2="taurenki z Wysokiej Góry", C2="taurence z Wysokiej Góry", B2="taurenkę z Wysokiej Góry", N2="taurenką z Wysokiej Góry", K2="taurence z Wysokiej Góry", W2="Highmountain Tauren" },
      ["Human"] = { M1="Człowiek", D1="człowieka", C1="człowiekowi", B1="człowieka", N1="człowiekiem", K1="człowieku", W1="Humano", M2="Człowiek", D2="człowieka", C2="człowiekowi", B2="człowieka", N2="człowiekiem", K2="człowieku", W2="Humana" },
      ["Kul Tiran"] = { M1="Kul Tiran", D1="Kul Tirana", C1="Kul Tiranowi", B1="Kul Tirana", N1="Kul Tiranem", K1="Kul Tiranie", W1="Kul Tiran", M2="Kul Tiranka", D2="Kul Tiranki", C2="Kul Tirance", B2="Kul Tirankę", N2="Kul Tiranką", K2="Kul Tirance", W2="Kul Tirana" },
      ["Lightforged Draenei"] = { M1="Świetlisty Draenei", D1="świetlistego draeneia", C1="świetlistemu draeneiowi", B1="świetlistego draeneia", N1="świetlistym draeneiem", K1="świetlistym draeneiu", W1="Lightforged Draenei", M2="Świetlista Draeneika", D2="świetlistej draeneiki", C2="świetlistej draeneice", B2="świetlistą draeneikę", N2="świetlistą draeneiką", K2="świetlistej draeneice", W2="Lightforged Draenei" },
      ["Mag'har Orc"] = { M1="Ork z Mag'har", D1="orka z Mag'har", C1="orkowi z Mag'har", B1="orka z Mag'har", N1="orkiem z Mag'har", K1="orku z Mag'har", W1="Mag'har Orc", M2="Orczyca z Mag'har", D2="orczycy z Mag'har", C2="orczycy z Mag'har", B2="orczycę z Mag'har", N2="orczycą z Mag'har", K2="orczyce z Mag'har", W2="Mag'har Orc" },
      ["Nightborne"] = { M1="Dziecię Nocy", D1="dziecięcia nocy", C1="dziecięciu nocy", B1="dziecię nocy", N1="dziecięcem nocy", K1="dziecięciu nocy", W1="Nightborne", M2="Dziecię Nocy", D2="dziecięcia nocy", C2="dziecięciu nocy", B2="dziecię nocy", N2="dziecięcem nocy", K2="dziecięciu nocy", W2="Nightborne" },
      ["Night Elf"] = { M1="Nocny Elf", D1="nocnego elfa", C1="nocnemu elfowi", B1="nocnego elfa", N1="nocnym elfem", K1="nocnym elfie", W1="Elfo Noturno", M2="Nocna Elfka", D2="nocnej elfki", C2="nocnej elfce", B2="nocną elfkę", N2="nocną elfką", K2="nocnej elfce", W2="Elfa Noturna" },
      ["Orc"] = { M1="Ork", D1="orka", C1="orkowi", B1="orka", N1="orkiem", K1="orku", W1="Orc", M2="Orczyca", D2="orczycy", C2="orczycy", B2="orczycę", N2="orczycą", K2="orczycy", W2="Orquisa" },
      ["Pandaren"] = { M1="Pandaren", D1="pandarena", C1="pondarenowi", B1="pandarena", N1="pandarenem", K1="pandarenie", W1="Pandaren", M2="Pandarenka", D2="pandarenki", C2="pondarence", B2="pandarenkę", N2="pandarenką", K2="pandarence", W2="Pandarena" },
      ["Tauren"] = { M1="Tauren", D1="taurena", C1="taurenowi", B1="taurena", N1="taurenem", K1="taurenie", W1="Tauren", M2="Taurenka", D2="taurenki", C2="taurence", B2="taurenkę", N2="taurenką", K2="taurence", W2="Taurena" },
      ["Troll"] = { M1="Troll", D1="trolla", C1="trollowi", B1="trolla", N1="trollem", K1="trollu", W1="Troll", M2="Trollica", D2="trollicy", C2="trollicy", B2="trollicę", N2="trollicą", K2="trollicy", W2="Trolesa" },
      ["Undead"] = { M1="Nieumarły", D1="nieumarłego", C1="nieumarłemu", B1="nieumarłego", N1="nieumarłym", K1="nieumarłym", W1="Morto-vivo", M2="Nieumarła", D2="nieumarłej", C2="nieumarłej", B2="nieumarłą", N2="nieumarłą", K2="nieumarłej", W2="Morta-viva" },
      ["Void Elf"] = { M1="Elf Pustki", D1="elfa Pustki", C1="elfowi Pustki", B1="elfa Pustki", N1="elfem Pustki", K1="elfie Pustki", W1="Void Elf", M2="Elfka Pustki", D2="elfki Pustki", C2="elfce Pustki", B2="elfkę Pustki", N2="elfką Pustki", K2="elfce Pustki", W2="Void Elf" },
      ["Worgen"] = { M1="Worgen", D1="worgena", C1="worgenowi", B1="worgena", N1="worgenem", K1="worgenie", W1="Worgen", M2="Worgenka", D2="worgenki", C2="worgence", B2="worgenkę", N2="worgenką", K2="worgence", W2="Worgenin" },
      ["Zandalari Troll"] = { M1="Troll Zandalari", D1="trolla Zandalari", C1="trollowi Zandalari", B1="trolla Zandalari", N1="trollem Zandalari", K1="trollu Zandalari", W1="Troll Zandalari", M2="Trollica Zandalari", D2="trollicy Zandalari", C2="trollicy Zandalari", B2="trollicę Zandalari", N2="trollicą Zandalari", K2="trollicy Zandalari", W2="Trolesa Zandalari" }, }
local p_class = {
      ["Death Knight"] = { M1="Rycerz Śmierci", D1="rycerz śmierci", C1="rycerzowi śmierci", B1="rycerza śmierci", N1="rycerzem śmierci", K1="rycerzu śmierci", W1="Cavaleiro da Morte", M2="Rycerz Śmierci", D2="rycerz śmierci", C2="rycerzowi śmierci", B2="rycerza śmierci", N2="rycerzem śmierci", K2="rycerzu śmierci", W2="Cavaleira da Morte" },
      ["Demon Hunter"] = { M1="Łowca demonów", D1="łowcy demonów", C1="łowcy demonów", B1="łowcę demonów", N1="łowcą demonów", K1="łowcy demonów", W1="Caçador de Demônios", M2="Łowczyni demonów", D2="łowczyni demonów", C2="łowczyni demonów", B2="łowczynię demonów", N2="łowczynią demonów", K2="łowczyni demonów", W2="Caçadora de Demônios" },
      ["Druid"] = { M1="Druid", D1="druida", C1="druidowi", B1="druida", N1="druidem", K1="druidzie", W1="Druida", M2="Druidka", D2="druidki", C2="druidce", B2="druikę", N2="druidką", K2="druidce", W2="Druidesa" },
      ["Hunter"] = { M1="Łowca", D1="łowcy", C1="łowcy", B1="łowcę", N1="łowcą", K1="łowcy", W1="Caçador", M2="Łowczyni", D2="łowczyni", C2="łowczyni", B2="łowczynię", N2="łowczynią", K2="łowczyni", W2="Caçadora" },
      ["Mage"] = { M1="Czarodziej", D1="czarodzieja", C1="czarodziejowi", B1="czarodzieja", N1="czarodziejem", K1="czarodzieju", W1="Mago", M2="Czarodziejka", D2="czarodziejki", C2="czarodziejce", B2="czarodziejkę", N2="czarodziejką", K2="czarodziejce", W2="Maga" },
      ["Monk"] = { M1="Mnich", D1="mnicha", C1="mnichowi", B1="mnicha", N1="mnichem", K1="mnichu", W1="Monge", M2="Mniszka", D2="mniszki", C2="mniszce", B2="mniszkę", N2="mniszką", K2="mniszce", W2="Monja" },
      ["Paladin"] = { M1="Paladyn", D1="paladyna", C1="paladynowi", B1="paladyna", N1="paladynem", K1="paladynie", W1="Paladino", M2="Paladynka", D2="paladynki", C2="paladynce", B2="paladynkę", N2="paladynką", K2="paladynce", W2="Paladina" },
      ["Priest"] = { M1="Kapłan", D1="kapłana", C1="kapłanowi", B1="kapłana", N1="kapłanem", K1="kapłanie", W1="Sacerdote", M2="Kapłanka", D2="kapłanki", C2="kapłance", B2="kapłankę", N2="kapłanką", K2="kapłance", W2="Sacerdotisa" },
      ["Rogue"] = { M1="Łotrzyk", D1="łotrzyka", C1="łotrzykowi", B1="łotrzyka", N1="łotrzykiem", K1="łotrzyku", W1="Ladino", M2="Łotrzyca", D2="łotrzycy", C2="łotrzycy", B2="łotrzycę", N2="łotrzycą", K2="łotrzycy", W2="Ladina" },
      ["Shaman"] = { M1="Szaman", D1="szamana", C1="szamanowi", B1="szamana", N1="szamanem", K1="szamanie", W1="Xamã", M2="Szamanka", D2="szamanki", C2="szamance", B2="szamankę", N2="szamanką", K2="szamance", W2="Xamã" },
      ["Warlock"] = { M1="Czarnoksiężnik", D1="czarnoksiężnika", C1="czarnoksiężnikowi", B1="czarnoksiężnika", N1="czarnoksiężnikiem", K1="czarnoksiężniku", W1="Bruxo", M2="Czarnoksiężniczka", D2="czarnoksiężniczki", C2="czarnoksiężniczce", B2="czarnoksiężniczkę", N2="czarnoksiężniczką", K2="czarnoksiężniczce", W2="Bruxa" },
      ["Warrior"] = { M1="Wojownik", D1="wojownika", C1="wojownikowi", B1="wojownika", N1="wojownikiem", K1="wojowniku", W1="Guerreiro", M2="Wojowniczka", D2="wojowniczki", C2="wojowniczce", B2="wojowniczkę", N2="wojowniczką", K2="wojowniczce", W2="Guerreira" }, }
if (p_race[QTR_race]) then      
   player_race = { M1=p_race[QTR_race].M1, D1=p_race[QTR_race].D1, C1=p_race[QTR_race].C1, B1=p_race[QTR_race].B1, N1=p_race[QTR_race].N1, K1=p_race[QTR_race].K1, W1=p_race[QTR_race].W1, M2=p_race[QTR_race].M2, D2=p_race[QTR_race].D2, C2=p_race[QTR_race].C2, B2=p_race[QTR_race].B2, N2=p_race[QTR_race].N2, K2=p_race[QTR_race].K2, W2=p_race[QTR_race].W2 };
else   
   player_race = { M1=QTR_race, D1=QTR_race, C1=QTR_race, B1=QTR_race, N1=QTR_race, K1=QTR_race, W1=QTR_race, M2=QTR_race, D2=QTR_race, C2=QTR_race, B2=QTR_race, N2=QTR_race, K2=QTR_race, W2=QTR_race };
  -- print ("|cff55ff00QTR - nowa rasa: "..QTR_race);
end
if (p_class[QTR_class]) then
   player_class = { M1=p_class[QTR_class].M1, D1=p_class[QTR_class].D1, C1=p_class[QTR_class].C1, B1=p_class[QTR_class].B1, N1=p_class[QTR_class].N1, K1=p_class[QTR_class].K1, W1=p_class[QTR_class].W1, M2=p_class[QTR_class].M2, D2=p_class[QTR_class].D2, C2=p_class[QTR_class].C2, B2=p_class[QTR_class].B2, N2=p_class[QTR_class].N2, K2=p_class[QTR_class].K2, W2=p_class[QTR_class].W2 };
else
   player_class = { M1=QTR_class, D1=QTR_class, C1=QTR_class, B1=QTR_class, N1=QTR_class, K1=QTR_class, W1=QTR_class, M2=QTR_class, D2=QTR_class, C2=QTR_class, B2=QTR_class, N2=QTR_class, K2=QTR_class, W2=QTR_class };
   --print ("|cff55ff00QTR - nowa klasa: "..QTR_class);
end


local function StringHash(text)           -- funkcja tworząca Hash (32-bitowa liczba) podanego tekstu 
  return QuestTradutor:StringHash(text);
end

-- Zmienne programowe zapisane na stałe na komputerze
function QuestTradutor:CheckVars()
  if (not QTR_PS) then
     QTR_PS = {};
  end
  if (not QTRTTT_PS) then
   QTRTTT_PS = {};
   end
  if (not QTR_MISSING) then
     QTR_MISSING = {};
  end 
  -- inicjalizacja: tłumaczenia włączone
  if (not QTR_PS["active"]) then
     QTR_PS["active"] = "1";
  end
  -- inicjalizacja: tłumaczenie tytułu questu włączone
  if (not QTR_PS["transtitle"] ) then
     QTR_PS["transtitle"] = "0";   
  end

  if (not QTR_PS["enablegoss"] ) then
      QTR_PS["enablegoss"] = "1";   
  end
  -- zmienna specjalna dostępności funkcji GetQuestID 
  if ( QTR_PS["isGetQuestID"] ) then
     isGetQuestID=QTR_PS["isGetQuestID"];
  end;
  -- okresowe wyświetlanie reklam o dodatku 
  if (not QTR_PS["reklama"] ) then
     QTR_PS["reklama"] = "1";
     QTR_PS["period"] = 15; 
     QTR_PS["channel"] = "0";
  end;
  if (not QTR_PS["other1"] ) then
     QTR_PS["other1"] = "1";
  end;
  if (not QTR_PS["other2"] ) then
     QTR_PS["other2"] = "1";
  end;
  if (not QTR_PS["other3"] ) then
     QTR_PS["other3"] = "1";
  end;
  if (not QTR_PS["channel"] ) then
     QTR_PS["channel"] = "0";
  end;
   -- zapis kontrolny oryginalnych questów EN
  if (not QTR_PS["control"]) then
     QTR_PS["control"] = "1";
  end
   -- zapis wersji patcha Wow'a
  if (not QTR_PS["patch"]) then
     QTR_PS["patch"] = GetBuildInfo();
  end

    -- initialize check options
    if (not QTRTTT_PS["active"] ) then
      QTRTTT_PS["active"] = "1";   
   end
   if (not QTRTTT_PS["showID"] ) then
      QTRTTT_PS["showID"] = "0";   
   end
   if (not QTRTTT_PS["saveNW"] ) then
      QTRTTT_PS["saveNW"] = "0";   
   end
   if (not QTRTTT_PS["saveWH"] ) then
      QTRTTT_PS["saveWH"] = "0";   
   end
   if (not QTRTTT_PS["compOR"] ) then
      QTRTTT_PS["compOR"] = "0";   
   end
   if (not QTRTTT_PS["body"] ) then
      QTRTTT_PS["body"] = "1";   
   end
   if (not QTRTTT_PS["mats"] ) then
      QTRTTT_PS["mats"] = "1";   
   end
   if (not QTRTTT_PS["weapon"] ) then
      QTRTTT_PS["weapon"] = "1";   
   end
   if (not QTRTTT_PS["info"] ) then
      QTRTTT_PS["info"] = "1";   
   end
   if (not QTRTTT_PS["ener"] ) then
      QTRTTT_PS["ener"] = "1";   
   end
   if (not QTRTTT_PS["try"] ) then
      QTRTTT_PS["try"] = "0";   
   end
   if(not QTRTTT_PS["isstat"]) then
      QTRTTT_PS["isstat"] = "1"
   end

   if (not QTRTTT_PS["questHelp"] ) then
      QTRTTT_PS["questHelp"] = "1";   
   end
  
  if(not QTR_FIXEDQUEST) then
     QTR_FIXEDQUEST = {};
  end
  if(not QTR_FIXEDITEM) then
     QTR_FIXEDITEM = {};
  end
  if(not QTR_FIXEDSPELL) then
     QTR_FIXEDSPELL = {};
  end 
 -- jeszcze nazwa gracza w przepadkach / per character
  if (not QTR_QUESTSTATUS) then
     QTR_QUESTSTATUS = {};
  end

  if(not QTR_PLAYERQUESTS) then
     QTR_PLAYERQUESTS = {};
  end

  if(not QTR_LASTCOMP) then
    QTR_LASTCOMP = {};
  end

   if(not QTR_LASTCOMP["id"]) then
      QTR_LASTCOMP["id"] = "0";
      QTR_LASTCOMP["completion"] = "";
      QTR_LASTCOMP["objectives"] = "";
      QTR_LASTCOMP["description"] = "";
      QTR_LASTCOMP["progress"] = "";
      QTR_LASTCOMP["completion"] = "";
   end 

  QTR_GS = {};       -- tablica na teksty oryginalne 
end 
-- Obsługa komend slash
function QuestTradutor:SlashCommand(msg)
   if (msg=="on" or msg=="ON") then
      if (QTR_PS["active"]=="1") then
         print ("QTR - traduções estão habilitadas.");
      else
         print ("|cffffff00QTR - ativando traduções");
         QTR_PS["active"] = "1";
         QTR_ToggleButton0:Enable();
         QTR_ToggleButton1:Enable();
         QTR_ToggleButton2:Enable(); 
         QTR_ToggleButtonWM:Enable();  
         if (QuestTradutor:isQuestGuru()) then
            QTR_ToggleButton3:Enable();
         end
         if (QuestTradutor:isImmersion()) then
            QTR_ToggleButton4:Enable();
         end
         QuestTradutor:Translate_On(1);
      end
   elseif (msg=="off" or msg=="OFF") then
      if (QTR_PS["active"]=="0") then
         print ("QTR - traduções estão desabilitadas.");
      else
         print ("|cffffff00QTR - desativando traduções.");
         QTR_PS["active"] = "0";
         QTR_ToggleButton0:Disable();
         QTR_ToggleButton1:Disable();
         QTR_ToggleButton2:Disable();
         QTR_ToggleButtonWM:Disable(); 
         if (QuestTradutorisQuestGuru()) then
            QTR_ToggleButton3:Disable();
         end
         if (QuestTradutorisImmersion()) then
            QTR_ToggleButton4:Disable();
         end  
         QuestTradutor:Translate_Off(1);
      end
   elseif (msg=="title on" or msg=="TITLE ON" or msg=="title 1") then
      if (QTR_PS["transtilte"]=="1") then
         print ("QTR - a tradução do título está ativada.");
      else
         print ("|cffffff00QTR - ativando a tradução do título.");
         QTR_PS["transtitle"] = "1";
         --QuestInfoTitleHeader:SetFont(QTR_Font1, 18);
      end
   elseif (msg=="title off" or msg=="TITLE OFF" or msg=="title 0") then
      if (QTR_PS["transtilte"]=="0") then
         print ("QTR - a tradução do título está desativada.");
      else
         print ("|cffffff00QTR - desativando a tradução do título.");
         QTR_PS["transtitle"] = "0";
         --QuestInfoTitleHeader:SetFont(Original_Font1, 18);
      end
   elseif (msg=="title" or msg=="TITLE") then
      if (QTR_PS["transtilte"]=="1") then
         print ("QTR - a tradução do título está ativada.");
      else
         print ("QTR - a tradução do título está desativada.");
      end
   elseif (msg=="") then 
      if(QuestTradutor.target < 3) then
         if(QTROptionsFrame) then
            if(QTROptionsFrame:IsVisible() and not QTROptionsFrame.QTRMoreOptions:IsVisible()) then
               QTROptionsFrame:Hide();
            elseif(not QTROptionsFrame:IsVisible() and QTROptionsFrame.QTRMoreOptions:IsVisible()) then
               QTROptionsFrame.QTRMoreOptions:Hide();
            else
               QTROptionsFrame:Show();
               QTROptionsFrame.QTRMoreOptions:Hide();
            end
         end
      else 
         InterfaceOptionsFrame_Show();
         InterfaceOptionsFrame_OpenToCategory("QuestTradutor");
      end  
   else
      print ("QTR - Quest Tradutor, lista de comandos:");
      print ("      /qtr  - Abre a janela de configurações do AddOn");
      print ("      /qtr on  - Ativa o AddOn");
      print ("      /qtr off - Desativa o AddOn");
      print ("      /qtr title on  - Ativa tradução dos titulos (cabeçalhos) das quests");
      print ("      /qtr title off - Desativa tradução dos titulos (cabeçalhos) das quests");
   end 
end



function QuestTradutor:SetCheckButtonState()
  QTRCheckButton0:SetChecked(QTR_PS["active"]=="1");
  QTRCheckButton3:SetChecked(QTR_PS["transtitle"]=="1");
  QTRCheckButton4:SetChecked(QTR_PS["enablegoss"]=="1"); 
  QTRCheckButton5:SetChecked(QTR_PS["reklama"]=="1");
  WowTranslatorCheckButton0:SetChecked(QTRTTT_PS["active"]=="1");
  WowTranslatorCheckButton1:SetChecked(QTRTTT_PS["showID"]=="1");
  WowTranslatorCheckButton4:SetChecked(QTRTTT_PS["body"]=="1");
  WowTranslatorCheckButton5:SetChecked(QTRTTT_PS["mats"]=="1");
  WowTranslatorCheckButton6:SetChecked(QTRTTT_PS["weapon"]=="1");
  WowTranslatorCheckButton9:SetChecked(QTRTTT_PS["ener"]=="1");
  WowTranslatorCheckButton7:SetChecked(QTRTTT_PS["info"]=="1");
  WowTranslatorCheckButton8:SetChecked(QTRTTT_PS["try"]=="1");
  WowTranslatorCheckButton10:SetChecked(QTRTTT_PS["questHelp"]=="1");
  WowTranslatorCheckButton11:SetChecked(QTRTTT_PS["isstat"]=="1");
end

local function QTR_BlizzardOptions()
  -- Create main frame for information text
   local QTROptionsFrame = CreateFrame("FRAME", "QuestTradutor_Options"); 

   QTROptionsScrollFrame = CreateFrame("ScrollFrame", "QTROptionsScroll", QTROptionsFrame, "UIPanelScrollFrameTemplate");
  
   QTROptionsScrollChild = QTROptionsScrollChild or CreateFrame("Frame");  
   local scrollbarName = QTROptionsScrollFrame:GetName()
   local qtrOptscrollbar = _G[scrollbarName.."ScrollBar"];
   local qtrOptscrollupbutton = _G[scrollbarName.."ScrollBarScrollUpButton"];
   local qtrOptscrolldownbutton = _G[scrollbarName.."ScrollBarScrollDownButton"];
   qtrOptscrollupbutton:ClearAllPoints();
   qtrOptscrollupbutton:SetPoint("TOPRIGHT", QTROptionsScrollFrame, "TOPRIGHT", -2, -2);
 
   qtrOptscrolldownbutton:ClearAllPoints();
   qtrOptscrolldownbutton:SetPoint("BOTTOMRIGHT", QTROptionsScrollFrame, "BOTTOMRIGHT", -2, 2);
 
   qtrOptscrollbar:ClearAllPoints();
   qtrOptscrollbar:SetPoint("TOP", qtrOptscrollupbutton, "BOTTOM", 0, -2);
   qtrOptscrollbar:SetPoint("BOTTOM", qtrOptscrolldownbutton, "TOP", 0, 2); 
   QTROptionsScrollFrame:SetScrollChild(QTROptionsScrollChild); 
   QTROptionsScrollFrame:SetAllPoints(QTROptionsFrame); 
   QTROptionsScrollChild:SetSize(InterfaceOptionsFramePanelContainer:GetWidth(), ( InterfaceOptionsFramePanelContainer:GetHeight() * 2.13 ));
   
   local QTROptions = CreateFrame("Frame", nil, QTROptionsScrollChild);
   QTROptions:SetAllPoints(QTROptionsScrollChild); 

   QTROptionsFrame.name = "QuestTradutor";
   QTROptionsFrame.refresh = function (self) QuestTradutor:SetCheckButtonState() end;
  InterfaceOptions_AddCategory(QTROptionsFrame);

  local QTROptionsHeader = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsHeader:SetFontObject(GameFontNormalLarge);
  QTROptionsHeader:SetJustifyH("LEFT"); 
  QTROptionsHeader:SetJustifyV("TOP");
  QTROptionsHeader:ClearAllPoints();
  QTROptionsHeader:SetPoint("TOPLEFT", 12, -12);
  QTROptionsHeader:SetText(string.format("QuestTradutor by Leandro ver. "..QTR_base..",\nbackport and merge of WoWpoPolsku-Quests\nand WowTranslator by Platine © 2010-2018"));

  local QTRDateOfBase = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRDateOfBase:SetFontObject(GameFontHighlightSmall);
  QTRDateOfBase:SetJustifyH("LEFT"); 
  QTRDateOfBase:SetJustifyV("TOP");
  QTRDateOfBase:ClearAllPoints();
  QTRDateOfBase:SetPoint("TOPLEFT", QTROptionsHeader, "TOPLEFT", 0, -60);
  QTRDateOfBase:SetText(string.format("Versão para WOTLK(3.3), TBC(2.4), Vanilla\n(1.12.1) e banco de dados feitos por Leandro.\nGithub: leoaviana/questtradutor "));
  QTRDateOfBase:SetFont(QTR_Font2, 16);

  local QTRCheckButton0 = CreateFrame("CheckButton", "QTRCheckButton0", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton0:SetPoint("TOPLEFT", QTROptionsHeader, "BOTTOMLEFT", 0, -70);
  QTRCheckButton0:SetScript("OnClick", function(self) if (QTR_PS["active"]=="1") then QTR_PS["active"]="0" else QTR_PS["active"]="1" end;end);  
  QTRCheckButton0Text:SetFont(QTR_Font2, 13);
  QTRCheckButton0Text:SetText(QTR_Interface.active);

  local QTROptionsMode1 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsMode1:SetFontObject(GameFontWhite);
  QTROptionsMode1:SetJustifyH("LEFT");
  QTROptionsMode1:SetJustifyV("TOP");
  QTROptionsMode1:ClearAllPoints();
  QTROptionsMode1:SetPoint("TOPLEFT", QTRCheckButton0, "BOTTOMLEFT", 20, -20);
  QTROptionsMode1:SetFont(QTR_Font2, 13);
  QTROptionsMode1:SetText(QTR_Interface.options1);
  
  local QTRCheckButton3 = CreateFrame("CheckButton", "QTRCheckButton3", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton3:SetPoint("TOPLEFT", QTROptionsMode1, "BOTTOMLEFT", 0, -5);
  QTRCheckButton3:SetScript("OnClick", function(self) if (QTR_PS["transtitle"]=="0") then QTR_PS["transtitle"]="1" else QTR_PS["transtitle"]="0" end; end);
  QTRCheckButton3Text:SetFont(QTR_Font2, 13);
  QTRCheckButton3Text:SetText(QTR_Interface.transtitle);

  local QTRCheckButton4 = CreateFrame("CheckButton", "QTRCheckButton4", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton4:SetPoint("TOPLEFT", QTROptionsMode1, "BOTTOMLEFT", 0, -30);
  QTRCheckButton4:SetScript("OnClick", function(self) if (QTR_PS["enablegoss"]=="0") then QTR_PS["enablegoss"]="1"; QTR_ToggleButtonGS:Show() else QTR_PS["enablegoss"]="0"; QTR_ToggleButtonGS:Hide()  end; end);
  QTRCheckButton4Text:SetFont(QTR_Font2, 13);
  QTRCheckButton4Text:SetText(QTR_Interface.enablegoss);

  local QTRCheckButton5 = CreateFrame("CheckButton", "QTRCheckButton5", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton5:SetPoint("TOPLEFT", QTROptionsMode1, "BOTTOMLEFT", 0, -50);
  QTRCheckButton5:SetScript("OnClick", function(self) if (QTR_PS["reklama"]=="0") then QTR_PS["reklama"]="1" else QTR_PS["reklama"]="0" end; end);
  QTRCheckButton5Text:SetFont(QTR_Font2, 13);
  QTRCheckButton5Text:SetText(QTR_Reklama.ON);
  
  local QTREditBox = CreateFrame("EditBox", "QTREditBox", QTROptions, "InputBoxTemplate");
  QTREditBox:SetPoint("TOPLEFT", QTRCheckButton5Text, "TOPRIGHT", 10, 3);
  QTREditBox:SetHeight(20);
  QTREditBox:SetWidth(20);
  QTREditBox:SetAutoFocus(false);
  QTREditBox:SetText(QTR_PS["channel"]);
  QTREditBox:SetCursorPosition(0);
  QTREditBox:SetScript("OnEnter", function(self)
   GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
    getglobal("GameTooltipTextLeft1"):SetFont(QTR_Font2, 13);
     GameTooltip:SetText(QTR_Reklama.CHANNEL, nil, nil, nil, nil, true)
   GameTooltip:Show() --Show the tooltip
   end);
   QTREditBox:SetScript("OnLeave", function(self)
    getglobal("GameTooltipTextLeft1"):SetFont(Original_Font2, 13);
   GameTooltip:Hide() --Hide the tooltip
   end);
  QTREditBox:SetScript("OnTextChanged", function(self) if (strlen(QTREditBox:GetText())>0) then QTR_PS["channel"]=QTREditBox:GetText() end; end);

  local QTRPeriodText = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRPeriodText:SetFontObject(GameFontWhite);
  QTRPeriodText:SetJustifyH("LEFT");
  QTRPeriodText:SetJustifyV("TOP");
  QTRPeriodText:ClearAllPoints();
  QTRPeriodText:SetPoint("TOPLEFT", QTRCheckButton5, "BOTTOMLEFT", 30, -20);
  QTRPeriodText:SetFont(QTR_Font2, 13);
  QTRPeriodText:SetText(QTR_Reklama.PERIOD);
  
  local QTR_slider = CreateFrame("Slider","MyAddonSlider",QTROptions,'OptionsSliderTemplate');
  QTR_slider:ClearAllPoints();
  QTR_slider:SetPoint("TOPLEFT",QTRPeriodText, "BOTTOMLEFT", 80, -30);
  
  getglobal(QTR_slider:GetName() .. 'Low'):SetText('5 min.');
  getglobal(QTR_slider:GetName() .. 'High'):SetText('90 min.');
  getglobal(QTR_slider:GetName() .. 'Text'):SetText(QTR_PS["period"] .. " min.");
  QTR_slider:SetMinMaxValues(5, 90);
  QTR_slider:SetValue(QTR_PS["period"]);
  QTR_slider:SetValueStep(5);
  QTR_slider:SetScript("OnValueChanged", function(self)
      QTR_PS["period"] = math.floor(QTR_slider:GetValue()+0.5);
      getglobal(QTR_slider:GetName() .. 'Text'):SetText(QTR_PS["period"] .. " min.");
      end);



local WowTranslatorOptionsStaff = QTROptions:CreateFontString(nil, "ARTWORK");
WowTranslatorOptionsStaff:SetFontObject(GameFontGreen);
WowTranslatorOptionsStaff:SetJustifyH("LEFT"); 
WowTranslatorOptionsStaff:SetJustifyV("TOP");
WowTranslatorOptionsStaff:ClearAllPoints();
WowTranslatorOptionsStaff:SetPoint("TOPLEFT", QTRCheckButton5, "BOTTOMLEFT", -15, -100);
WowTranslatorOptionsStaff:SetFont(WT_Font, 14);
WowTranslatorOptionsStaff:SetText("-----------------------------------------------------------------");


local WowTranslatorOptionsStaff1 = QTROptions:CreateFontString(nil, "ARTWORK");
WowTranslatorOptionsStaff1:SetFontObject(GameFontWhite);
WowTranslatorOptionsStaff1:SetJustifyH("LEFT"); 
WowTranslatorOptionsStaff1:SetJustifyV("TOP");
WowTranslatorOptionsStaff1:ClearAllPoints();
WowTranslatorOptionsStaff1:SetPoint("TOPLEFT", WowTranslatorOptionsStaff, "BOTTOMLEFT", 0, -20);
WowTranslatorOptionsStaff1:SetFont(WT_Font, 12);
WowTranslatorOptionsStaff1:SetText(WT_Interface.WTInfo);

local WowTranslatorCheckButton0 = CreateFrame("CheckButton", "WowTranslatorCheckButton0", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton0:SetPoint("TOPLEFT", WowTranslatorOptionsStaff1, "BOTTOMLEFT", 0, -10);
WowTranslatorCheckButton0:SetScript("OnClick", function(self) if (QTRTTT_PS["active"]=="1") then QTRTTT_PS["active"]="0" else QTRTTT_PS["active"]="1" end; end);
WowTranslatorCheckButton0Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton0Text:SetText(WT_Interface.active);

local WowTranslatorOptionsMode = QTROptions:CreateFontString(nil, "ARTWORK");
WowTranslatorOptionsMode:SetFontObject(GameFontWhite);
WowTranslatorOptionsMode:SetJustifyH("LEFT"); 
WowTranslatorOptionsMode:SetJustifyV("TOP");
WowTranslatorOptionsMode:ClearAllPoints();
WowTranslatorOptionsMode:SetPoint("TOPLEFT", WowTranslatorCheckButton0, "BOTTOMLEFT", 0, -20);
WowTranslatorOptionsMode:SetFont(WT_Font, 13);
WowTranslatorOptionsMode:SetText(WT_Interface.mode);

local WowTranslatorCheckButton1 = CreateFrame("CheckButton", "WowTranslatorCheckButton1", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton1:SetPoint("TOPLEFT", WowTranslatorOptionsMode, "BOTTOMLEFT", 2, -4);
WowTranslatorCheckButton1:SetScript("OnClick", function(self) if (QTRTTT_PS["showID"]=="1") then QTRTTT_PS["showID"]="0" else QTRTTT_PS["showID"]="1" end; end);
WowTranslatorCheckButton1Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton1Text:SetText(WT_Interface.showID);

local WowTranslatorCheckButton2 = CreateFrame("CheckButton", "WowTranslatorCheckButton2", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton2:SetPoint("TOPLEFT", WowTranslatorCheckButton1, "BOTTOMLEFT", 0, 0);
WowTranslatorCheckButton2:SetScript("OnClick", function(self) return end);
WowTranslatorCheckButton2Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton2Text:SetText(WT_Interface.saveNW);
WowTranslatorCheckButton2:Hide();

-- local WowTranslatorCheckButton2b = CreateFrame("CheckButton", "WowTranslatorCheckButton2b", QTROptions, "OptionsCheckButtonTemplate");
-- WowTranslatorCheckButton2b:SetPoint("TOPLEFT", WowTranslatorCheckButton2Text, "TOPRIGHT", 24, 6);
-- WowTranslatorCheckButton2b:SetScript("OnClick", function(self) QTRTTT_PS["saveWH"] = not QTRTTT_PS["saveWH"]; end);
-- WowTranslatorCheckButton2bText:SetFont(WT_Font, 13);
-- WowTranslatorCheckButton2bText:SetText(WT_Interface.saveWH);

--local WowTranslatorCheckButton3 = CreateFrame("CheckButton", "WowTranslatorCheckButton3", QTROptions, "OptionsCheckButtonTemplate");
--WowTranslatorCheckButton3:SetPoint("TOPLEFT", WowTranslatorCheckButton2, "BOTTOMLEFT", 0, 0);
--WowTranslatorCheckButton3:SetScript("OnClick", function(self) QTRTTT_PS["compOR"] = not QTRTTT_PS["compOR"]; end);
--WowTranslatorCheckButton3Text:SetFont(WT_Font, 13);
--WowTranslatorCheckButton3Text:SetText(WT_Interface.compOR);


local WowTranslatorOptionsOnTheFly = QTROptions:CreateFontString(nil, "ARTWORK");
WowTranslatorOptionsOnTheFly:SetFontObject(GameFontWhite);
WowTranslatorOptionsOnTheFly:SetJustifyH("LEFT");
WowTranslatorOptionsOnTheFly:SetJustifyV("TOP");
WowTranslatorOptionsOnTheFly:ClearAllPoints();
WowTranslatorOptionsOnTheFly:SetPoint("TOPLEFT", WowTranslatorCheckButton2, "BOTTOMLEFT", -2, -20);
WowTranslatorOptionsOnTheFly:SetFont(WT_Font, 13);
WowTranslatorOptionsOnTheFly:SetText(WT_Interface.transl);

local WowTranslatorCheckButton4 = CreateFrame("CheckButton", "WowTranslatorCheckButton4", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton4:SetPoint("TOPLEFT", WowTranslatorOptionsOnTheFly, "BOTTOMLEFT", 0, -4);
WowTranslatorCheckButton4:SetScript("OnClick", function(self) if (QTRTTT_PS["body"]=="1") then QTRTTT_PS["body"]="0" else QTRTTT_PS["body"]="1" end; end);
WowTranslatorCheckButton4Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton4Text:SetText(WT_Interface.body);

local WowTranslatorCheckButton5 = CreateFrame("CheckButton", "WowTranslatorCheckButton5", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton5:SetPoint("TOPLEFT", WowTranslatorCheckButton4, "BOTTOMLEFT", 0, 0);
WowTranslatorCheckButton5:SetScript("OnClick", function(self) if (QTRTTT_PS["mats"]=="1") then QTRTTT_PS["mats"]="0" else QTRTTT_PS["mats"]="1" end; end);
WowTranslatorCheckButton5Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton5Text:SetText(WT_Interface.mats);

local WowTranslatorCheckButton6 = CreateFrame("CheckButton", "WowTranslatorCheckButton6", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton6:SetPoint("TOPLEFT", WowTranslatorCheckButton5, "BOTTOMLEFT", 0, 0);
WowTranslatorCheckButton6:SetScript("OnClick", function(self) if (QTRTTT_PS["weapon"]=="1") then QTRTTT_PS["weapon"]="0" else QTRTTT_PS["weapon"]="1" end; end);
WowTranslatorCheckButton6Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton6Text:SetText(WT_Interface.weapon);

local WowTranslatorCheckButton9 = CreateFrame("CheckButton", "WowTranslatorCheckButton9", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton9:SetPoint("TOPLEFT", WowTranslatorCheckButton6, "BOTTOMLEFT", 0, 0);
WowTranslatorCheckButton9:SetScript("OnClick", function(self) if (QTRTTT_PS["ener"]=="1") then QTRTTT_PS["ener"]="0" else QTRTTT_PS["ener"]="1" end; end);
WowTranslatorCheckButton9Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton9Text:SetText(WT_Interface.ener);

local WowTranslatorCheckButton7 = CreateFrame("CheckButton", "WowTranslatorCheckButton7", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton7:SetPoint("TOPLEFT", WowTranslatorCheckButton9, "BOTTOMLEFT", 0, 0);
WowTranslatorCheckButton7:SetScript("OnClick", function(self) if (QTRTTT_PS["info"]=="1") then QTRTTT_PS["info"]="0" else QTRTTT_PS["info"]="1" end; end);
WowTranslatorCheckButton7Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton7Text:SetText(WT_Interface.info);

local WowTranslatorCheckButton11 = CreateFrame("CheckButton", "WowTranslatorCheckButton11", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton11:SetPoint("TOPLEFT", WowTranslatorCheckButton7, "BOTTOMLEFT", 0, 0);
WowTranslatorCheckButton11:SetScript("OnClick", function(self) if (QTRTTT_PS["isstat"]=="1") then QTRTTT_PS["isstat"]="0" else QTRTTT_PS["isstat"]="1" end; end);
WowTranslatorCheckButton11Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton11Text:SetText(WT_Interface.stats);

local WowTranslatorCheckButton8 = CreateFrame("CheckButton", "WowTranslatorCheckButton8", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton8:SetPoint("TOPLEFT", WowTranslatorCheckButton11, "BOTTOMLEFT", 0, -10);
WowTranslatorCheckButton8:SetScript("OnClick", function(self) if (QTRTTT_PS["try"]=="1") then QTRTTT_PS["try"]="0" else QTRTTT_PS["try"]="1" end; end);
WowTranslatorCheckButton8Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton8Text:SetText(WT_Interface.try);

local WowTranslatorCheckButton10 = CreateFrame("CheckButton", "WowTranslatorCheckButton10", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton10:SetPoint("TOPLEFT", WowTranslatorCheckButton8, "BOTTOMLEFT", 0, 0);
WowTranslatorCheckButton10:SetScript("OnClick", function(self) if (QTRTTT_PS["questHelp"]=="1") then QTRTTT_PS["questHelp"]="0" else QTRTTT_PS["questHelp"]="1" end; end);
WowTranslatorCheckButton10Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton10Text:SetText(WT_Interface.questHelp);

local QTRCommandsLBL = QTROptions:CreateFontString(nil, "ARTWORK");
QTRCommandsLBL:SetFontObject(GameFontWhite);
QTRCommandsLBL:SetJustifyH("LEFT"); 
QTRCommandsLBL:SetJustifyV("TOP");
QTRCommandsLBL:ClearAllPoints();
QTRCommandsLBL:SetPoint("TOPLEFT", WowTranslatorCheckButton10, "BOTTOMLEFT", 0, -20);
QTRCommandsLBL:SetFont(WT_Font, 12);
QTRCommandsLBL:SetText(QTR_Interface.commands);
  
end 

function QuestTradutor:LoadOptionsFrame()   
  -- Create main frame for information text
   
   if(QuestTradutor.target > 2) then
      QTR_BlizzardOptions()
      return
   end
   
   QTROptionsFrame = CreateFrame("FRAME", "QuestTradutor_Options"); 
   QTROptionsFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
   edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
   tile = true, tileSize = 16, edgeSize = 16, 
   insets = { left = 4, right = 4, top = 4, bottom = 4 }});
   QTROptionsFrame:SetBackdropColor(0,0,0,1); 
   QTROptionsFrame:SetPoint("CENTER",0,0);
   QTROptionsFrame:SetWidth(500)
   QTROptionsFrame:SetFrameStrata("DIALOG")
   QTROptionsFrame:SetHeight(600) 
   QTROptionsFrame:Hide();

   
   local QTROptions = QTROptionsFrame
   
   QTROptions:SetScript("OnUpdate", function () QuestTradutor:SetCheckButtonState() end);


  local QTROptionsHeader = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsHeader:SetFontObject(GameFontNormalLarge);
  QTROptionsHeader:SetJustifyH("LEFT"); 
  QTROptionsHeader:SetJustifyV("TOP");
  QTROptionsHeader:ClearAllPoints();
  QTROptionsHeader:SetPoint("TOPLEFT", 12, -12);
  QTROptionsHeader:SetText(string.format("QuestTradutor by Leandro ver. "..QTR_base..",\nbackport and merge of WoWpoPolsku-Quests\nand WowTranslator by Platine © 2010-2018"));

  

  local QTR_CloseBtn = CreateFrame("Button",nil, QTROptions, "UIPanelButtonTemplate");
  QTR_CloseBtn:SetWidth(35);
  QTR_CloseBtn:SetHeight(25);
  QTR_CloseBtn:SetText("X"); 
  QTR_CloseBtn:Show();
  QTR_CloseBtn:ClearAllPoints();
  QTR_CloseBtn:SetPoint("TOPRIGHT", -5, -5);
  QTR_CloseBtn:SetScript("OnClick", function() QTROptions:Hide() end);


  local QTRDateOfBase = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRDateOfBase:SetFontObject(GameFontHighlightSmall);
  QTRDateOfBase:SetJustifyH("LEFT"); 
  QTRDateOfBase:SetJustifyV("TOP");
  QTRDateOfBase:ClearAllPoints();
  QTRDateOfBase:SetPoint("TOPLEFT", QTROptionsHeader, "TOPLEFT", 0, -50);
  QTRDateOfBase:SetText(string.format("Versão para WOTLK(3.3), TBC(2.4), Vanilla  (1.12.1) e \nbanco de dados feitos por Leandro, Github: leoaviana/questtradutor "));
  QTRDateOfBase:SetFont(QTR_Font2, 16);


  local QTRCheckButton0 = CreateFrame("CheckButton", "QTRCheckButton0", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton0:SetPoint("TOPLEFT", QTROptionsHeader, "BOTTOMLEFT", 0, -40);
  QTRCheckButton0:SetScript("OnClick", function(self) if (QTR_PS["active"]=="1") then QTR_PS["active"]="0" else QTR_PS["active"]="1" end;end);  
  QTRCheckButton0Text:SetFont(QTR_Font2, 13);
  QTRCheckButton0Text:SetText(QTR_Interface.active);
  

  local QTROptionsMode1 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsMode1:SetFontObject(GameFontWhite);
  QTROptionsMode1:SetJustifyH("LEFT");
  QTROptionsMode1:SetJustifyV("TOP");
  QTROptionsMode1:ClearAllPoints();
  QTROptionsMode1:SetPoint("TOPLEFT", QTRCheckButton0, "BOTTOMLEFT", 20, -10);
  QTROptionsMode1:SetFont(QTR_Font2, 13);
  QTROptionsMode1:SetText(QTR_Interface.options1);
  
  local QTRCheckButton3 = CreateFrame("CheckButton", "QTRCheckButton3", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton3:SetPoint("TOPLEFT", QTROptionsMode1, "BOTTOMLEFT", 0, -5);
  QTRCheckButton3:SetScript("OnClick", function(self) if (QTR_PS["transtitle"]=="0") then QTR_PS["transtitle"]="1" else QTR_PS["transtitle"]="0" end; end);
  QTRCheckButton3Text:SetFont(QTR_Font2, 13);
  QTRCheckButton3Text:SetText(QTR_Interface.transtitle);

  local QTRCheckButton4 = CreateFrame("CheckButton", "QTRCheckButton4", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton4:SetPoint("TOPLEFT", QTROptionsMode1, "BOTTOMLEFT", 0, -30);
  QTRCheckButton4:SetScript("OnClick", function(self) if (QTR_PS["enablegoss"]=="0") then QTR_PS["enablegoss"]="1"; QTR_ToggleButtonGS:Show() else QTR_PS["enablegoss"]="0"; QTR_ToggleButtonGS:Hide()  end; end);
  QTRCheckButton4Text:SetFont(QTR_Font2, 13);
  QTRCheckButton4Text:SetText(QTR_Interface.enablegoss);

  local QTRCheckButton5 = CreateFrame("CheckButton", "QTRCheckButton5", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton5:SetPoint("TOPLEFT", QTROptionsMode1, "BOTTOMLEFT", 0, -50);
  QTRCheckButton5:SetScript("OnClick", function(self) if (QTR_PS["reklama"]=="0") then QTR_PS["reklama"]="1" else QTR_PS["reklama"]="0" end; end);
  QTRCheckButton5Text:SetFont(QTR_Font2, 13);
  QTRCheckButton5Text:SetText(QTR_Reklama.ON);
  
  local QTREditBox = CreateFrame("EditBox", "QTREditBox", QTROptions, "InputBoxTemplate");
  QTREditBox:SetPoint("TOPLEFT", QTRCheckButton5Text, "TOPRIGHT", 10, 3);
  QTREditBox:SetHeight(20);
  QTREditBox:SetWidth(20);
  QTREditBox:SetAutoFocus(false);
  QTREditBox:SetText(QTR_PS["channel"]); 
  QTREditBox:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(QTREditBox, "ANCHOR_TOPRIGHT") 
      GameTooltip:SetText(QTR_Reklama.CHANNEL, nil, nil, nil, nil, true)
      GameTooltip:Show() --Show the tooltip
   end);
   QTREditBox:SetScript("OnLeave", function(self) 
   GameTooltip:Hide() --Hide the tooltip
   end);
  QTREditBox:SetScript("OnTextChanged", function(self) if (strlen(QTREditBox:GetText())>0) then QTR_PS["channel"]=QTREditBox:GetText() end; end);

  local QTRPeriodText = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRPeriodText:SetFontObject(GameFontWhite);
  QTRPeriodText:SetJustifyH("LEFT");
  QTRPeriodText:SetJustifyV("TOP");
  QTRPeriodText:ClearAllPoints();
  QTRPeriodText:SetPoint("TOPLEFT", QTRCheckButton5, "BOTTOMLEFT", 30, -10);
  QTRPeriodText:SetFont(QTR_Font2, 13);
  QTRPeriodText:SetText(QTR_Reklama.PERIOD);
  
  local QTR_slider = CreateFrame("Slider","MyAddonSlider",QTROptions,'OptionsSliderTemplate');
  QTR_slider:ClearAllPoints();
  QTR_slider:SetPoint("TOPLEFT",QTRPeriodText, "BOTTOMLEFT", 80, -30);
  
  getglobal(QTR_slider:GetName() .. 'Low'):SetText('5 min.');
  getglobal(QTR_slider:GetName() .. 'High'):SetText('90 min.');
  getglobal(QTR_slider:GetName() .. 'Text'):SetText(QTR_PS["period"] .. " min.");
  QTR_slider:SetMinMaxValues(5, 90);
  QTR_slider:SetValue(QTR_PS["period"]);
  QTR_slider:SetValueStep(5);
  QTR_slider:SetScript("OnValueChanged", function(self)
      QTR_PS["period"] = math.floor(QTR_slider:GetValue()+0.5);
      getglobal(QTR_slider:GetName() .. 'Text'):SetText(QTR_PS["period"] .. " min.");
      end); 


local WowTranslatorOptionsStaff1 = QTROptions:CreateFontString(nil, "ARTWORK");
WowTranslatorOptionsStaff1:SetFontObject(GameFontWhite);
WowTranslatorOptionsStaff1:SetJustifyH("LEFT"); 
WowTranslatorOptionsStaff1:SetJustifyV("TOP");
WowTranslatorOptionsStaff1:ClearAllPoints();
WowTranslatorOptionsStaff1:SetPoint("TOPRIGHT", QTRCheckButton5, "BOTTOMRIGHT", 250, -100);
WowTranslatorOptionsStaff1:SetFont(WT_Font, 12);
WowTranslatorOptionsStaff1:SetText(WT_Interface.WTInfo);

local WowTranslatorCheckButton0 = CreateFrame("CheckButton", "WowTranslatorCheckButton0", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton0:SetPoint("TOPLEFT", WowTranslatorOptionsStaff1, "BOTTOMLEFT", 0, -10);
WowTranslatorCheckButton0:SetScript("OnClick", function(self) if (QTRTTT_PS["active"]=="1") then QTRTTT_PS["active"]="0" else QTRTTT_PS["active"]="1" end; end);
WowTranslatorCheckButton0Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton0Text:SetText(WT_Interface.active);

local WowTranslatorOptionsMode = QTROptions:CreateFontString(nil, "ARTWORK");
WowTranslatorOptionsMode:SetFontObject(GameFontWhite);
WowTranslatorOptionsMode:SetJustifyH("LEFT"); 
WowTranslatorOptionsMode:SetJustifyV("TOP");
WowTranslatorOptionsMode:ClearAllPoints();
WowTranslatorOptionsMode:SetPoint("TOPLEFT", WowTranslatorCheckButton0, "BOTTOMLEFT", 0, -5);
WowTranslatorOptionsMode:SetFont(WT_Font, 13);
WowTranslatorOptionsMode:SetText(WT_Interface.mode);

local WowTranslatorCheckButton1 = CreateFrame("CheckButton", "WowTranslatorCheckButton1", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton1:SetPoint("TOPLEFT", WowTranslatorOptionsMode, "BOTTOMLEFT", 2, -4);
WowTranslatorCheckButton1:SetScript("OnClick", function(self) if (QTRTTT_PS["showID"]=="1") then QTRTTT_PS["showID"]="0" else QTRTTT_PS["showID"]="1" end; end);
WowTranslatorCheckButton1Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton1Text:SetText(WT_Interface.showID); 

local WowTranslatorOptionsOnTheFly = QTROptions:CreateFontString(nil, "ARTWORK");
WowTranslatorOptionsOnTheFly:SetFontObject(GameFontWhite);
WowTranslatorOptionsOnTheFly:SetJustifyH("LEFT");
WowTranslatorOptionsOnTheFly:SetJustifyV("TOP");
WowTranslatorOptionsOnTheFly:ClearAllPoints();
WowTranslatorOptionsOnTheFly:SetPoint("TOPLEFT", WowTranslatorCheckButton1, "TOPLEFT", -2, -30);
WowTranslatorOptionsOnTheFly:SetFont(WT_Font, 13);
WowTranslatorOptionsOnTheFly:SetText(WT_Interface.transl);


local WowTranslatorCheckButton10 = CreateFrame("CheckButton", "WowTranslatorCheckButton10", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton10:SetPoint("TOPLEFT", WowTranslatorCheckButton1, "BOTTOMLEFT", 0, -15);
WowTranslatorCheckButton10:SetScript("OnClick", function(self) if (QTRTTT_PS["questHelp"]=="1") then QTRTTT_PS["questHelp"]="0" else QTRTTT_PS["questHelp"]="1" end; end);
WowTranslatorCheckButton10Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton10Text:SetText(WT_Interface.questHelp);


local WowTranslatorCheckButton8 = CreateFrame("CheckButton", "WowTranslatorCheckButton8", QTROptions, "OptionsCheckButtonTemplate");
WowTranslatorCheckButton8:SetPoint("TOPLEFT", WowTranslatorCheckButton10, "BOTTOMLEFT", 0, 0);
WowTranslatorCheckButton8:SetScript("OnClick", function(self) if (QTRTTT_PS["try"]=="1") then QTRTTT_PS["try"]="0" else QTRTTT_PS["try"]="1" end; end);
WowTranslatorCheckButton8Text:SetFont(WT_Font, 13);
WowTranslatorCheckButton8Text:SetText(WT_Interface.try);


-----------------------------------------------------------------------------------------------------------------------------------------------

local QTRMoreOptions = CreateFrame("FRAME", "QuestTradutor_MoreOptions"); 
QTRMoreOptions:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
tile = true, tileSize = 16, edgeSize = 16, 
insets = { left = 4, right = 4, top = 4, bottom = 4 }});
QTRMoreOptions:SetBackdropColor(0,0,0,1); 
QTRMoreOptions:SetPoint("CENTER",0,0);
QTRMoreOptions:SetWidth(500)
QTRMoreOptions:SetFrameStrata("DIALOG")
QTRMoreOptions:SetHeight(600) 
QTRMoreOptions:Hide();
QTROptions.QTRMoreOptions = QTRMoreOptions;
 
QTRMoreOptions:SetScript("OnUpdate", function () QuestTradutor:SetCheckButtonState() end);

local QTROptionsHeaderM = QTRMoreOptions:CreateFontString(nil, "ARTWORK");
  QTROptionsHeaderM:SetFontObject(GameFontNormalLarge);
  QTROptionsHeaderM:SetJustifyH("LEFT"); 
  QTROptionsHeaderM:SetJustifyV("TOP");
  QTROptionsHeaderM:ClearAllPoints();
  QTROptionsHeaderM:SetPoint("TOPLEFT", 12, -12);
  QTROptionsHeaderM:SetText(string.format("QuestTradutor by Leandro ver. "..QTR_base..",\nbackport and merge of WoWpoPolsku-Quests\nand WowTranslator by Platine © 2010-2018"));

  

  local QTR_CloseBtnM = CreateFrame("Button",nil, QTRMoreOptions, "UIPanelButtonTemplate");
  QTR_CloseBtnM:SetWidth(35);
  QTR_CloseBtnM:SetHeight(25);
  QTR_CloseBtnM:SetText("X"); 
  QTR_CloseBtnM:Show();
  QTR_CloseBtnM:ClearAllPoints();
  QTR_CloseBtnM:SetPoint("TOPRIGHT", -5, -5);
  QTR_CloseBtnM:SetScript("OnClick", function() QTROptions:Show() QTRMoreOptions:Hide() end);


  local QTRDateOfBaseM = QTRMoreOptions:CreateFontString(nil, "ARTWORK");
  QTRDateOfBaseM:SetFontObject(GameFontHighlightSmall);
  QTRDateOfBaseM:SetJustifyH("LEFT"); 
  QTRDateOfBaseM:SetJustifyV("TOP");
  QTRDateOfBaseM:ClearAllPoints();
  QTRDateOfBaseM:SetPoint("TOPLEFT", QTROptionsHeader, "TOPLEFT", 0, -50);
  QTRDateOfBaseM:SetText(string.format("Versão para WOTLK(3.3), TBC(2.4), Vanilla  (1.12.1) e \nbanco de dados feitos por Leandro, Github @leoaviana "));
  QTRDateOfBaseM:SetFont(QTR_Font2, 16);

  
local WowTranslatorOptionsOnTheFlyM = QTRMoreOptions:CreateFontString(nil, "ARTWORK");
WowTranslatorOptionsOnTheFlyM:SetFontObject(GameFontWhite);
WowTranslatorOptionsOnTheFlyM:SetJustifyH("LEFT");
WowTranslatorOptionsOnTheFlyM:SetJustifyV("TOP");
WowTranslatorOptionsOnTheFlyM:ClearAllPoints();
WowTranslatorOptionsOnTheFlyM:SetPoint("TOPLEFT", QTRDateOfBaseM, "TOPLEFT", 0, -50);
WowTranslatorOptionsOnTheFlyM:SetFont(WT_Font, 13);
WowTranslatorOptionsOnTheFlyM:SetText(WT_Interface.transl);


  local WowTranslatorCheckButton4 = CreateFrame("CheckButton", "WowTranslatorCheckButton4", QTRMoreOptions, "OptionsCheckButtonTemplate");
  WowTranslatorCheckButton4:SetPoint("TOPLEFT", WowTranslatorOptionsOnTheFlyM, "BOTTOMLEFT", 0, -4);
  WowTranslatorCheckButton4:SetScript("OnClick", function(self) if (QTRTTT_PS["body"]=="1") then QTRTTT_PS["body"]="0" else QTRTTT_PS["body"]="1" end; end);
  WowTranslatorCheckButton4Text:SetFont(WT_Font, 13);
  WowTranslatorCheckButton4Text:SetText(WT_Interface.body);
  
  local WowTranslatorCheckButton5 = CreateFrame("CheckButton", "WowTranslatorCheckButton5", QTRMoreOptions, "OptionsCheckButtonTemplate");
  WowTranslatorCheckButton5:SetPoint("TOPLEFT", WowTranslatorCheckButton4, "BOTTOMLEFT", 0, 0);
  WowTranslatorCheckButton5:SetScript("OnClick", function(self) if (QTRTTT_PS["mats"]=="1") then QTRTTT_PS["mats"]="0" else QTRTTT_PS["mats"]="1" end; end);
  WowTranslatorCheckButton5Text:SetFont(WT_Font, 13);
  WowTranslatorCheckButton5Text:SetText(WT_Interface.mats);
  
  local WowTranslatorCheckButton6 = CreateFrame("CheckButton", "WowTranslatorCheckButton6", QTRMoreOptions, "OptionsCheckButtonTemplate");
  WowTranslatorCheckButton6:SetPoint("TOPLEFT", WowTranslatorCheckButton5, "BOTTOMLEFT", 0, 0);
  WowTranslatorCheckButton6:SetScript("OnClick", function(self) if (QTRTTT_PS["weapon"]=="1") then QTRTTT_PS["weapon"]="0" else QTRTTT_PS["weapon"]="1" end; end);
  WowTranslatorCheckButton6Text:SetFont(WT_Font, 13);
  WowTranslatorCheckButton6Text:SetText(WT_Interface.weapon);
  
  local WowTranslatorCheckButton9 = CreateFrame("CheckButton", "WowTranslatorCheckButton9", QTRMoreOptions, "OptionsCheckButtonTemplate");
  WowTranslatorCheckButton9:SetPoint("TOPLEFT", WowTranslatorCheckButton6, "BOTTOMLEFT", 0, 0);
  WowTranslatorCheckButton9:SetScript("OnClick", function(self) if (QTRTTT_PS["ener"]=="1") then QTRTTT_PS["ener"]="0" else QTRTTT_PS["ener"]="1" end; end);
  WowTranslatorCheckButton9Text:SetFont(WT_Font, 13);
  WowTranslatorCheckButton9Text:SetText(WT_Interface.ener);
  
  local WowTranslatorCheckButton7 = CreateFrame("CheckButton", "WowTranslatorCheckButton7", QTRMoreOptions, "OptionsCheckButtonTemplate");
  WowTranslatorCheckButton7:SetPoint("TOPLEFT", WowTranslatorCheckButton9, "BOTTOMLEFT", 0, 0);
  WowTranslatorCheckButton7:SetScript("OnClick", function(self) if (QTRTTT_PS["info"]=="1") then QTRTTT_PS["info"]="0" else QTRTTT_PS["info"]="1" end; end);
  WowTranslatorCheckButton7Text:SetFont(WT_Font, 13);
  WowTranslatorCheckButton7Text:SetText(WT_Interface.info);
  
  local WowTranslatorCheckButton11 = CreateFrame("CheckButton", "WowTranslatorCheckButton11", QTRMoreOptions, "OptionsCheckButtonTemplate");
  WowTranslatorCheckButton11:SetPoint("TOPLEFT", WowTranslatorCheckButton7, "BOTTOMLEFT", 0, 0);
  WowTranslatorCheckButton11:SetScript("OnClick", function(self) if (QTRTTT_PS["isstat"]=="1") then QTRTTT_PS["isstat"]="0" else QTRTTT_PS["isstat"]="1" end; end);
  WowTranslatorCheckButton11Text:SetFont(WT_Font, 13);
  WowTranslatorCheckButton11Text:SetText(WT_Interface.stats);

  
local QTR_GoBackBtn = CreateFrame("Button",nil, QTRMoreOptions, "UIPanelButtonTemplate");
QTR_GoBackBtn:SetWidth(90);
QTR_GoBackBtn:SetHeight(25);
QTR_GoBackBtn:SetText("<- Voltar"); 
QTR_GoBackBtn:Show();
QTR_GoBackBtn:ClearAllPoints();
QTR_GoBackBtn:SetPoint("TOPLEFT", WowTranslatorCheckButton11, "BOTTOMRIGHT", 360, -215);
QTR_GoBackBtn:SetScript("OnClick", function() QTROptions:Show() QTRMoreOptions:Hide() end);


-----------------------------------------------------------------------------------------------------------------------------


local QTR_MoreOptionsBtn = CreateFrame("Button",nil, QTROptions, "UIPanelButtonTemplate");
QTR_MoreOptionsBtn:SetWidth(90);
QTR_MoreOptionsBtn:SetHeight(25);
QTR_MoreOptionsBtn:SetText("Mais Opções"); 
QTR_MoreOptionsBtn:Show();
QTR_MoreOptionsBtn:ClearAllPoints();
QTR_MoreOptionsBtn:SetPoint("TOPLEFT", WowTranslatorCheckButton8, "BOTTOMRIGHT", 350, 0);
QTR_MoreOptionsBtn:SetScript("OnClick", function() QTROptions:Hide() QTRMoreOptions:Show() end);


local QTRCommandsLBL = QTROptions:CreateFontString(nil, "ARTWORK");
QTRCommandsLBL:SetFontObject(GameFontWhite);
QTRCommandsLBL:SetJustifyH("LEFT"); 
QTRCommandsLBL:SetJustifyV("TOP");
QTRCommandsLBL:ClearAllPoints();
QTRCommandsLBL:SetPoint("TOPLEFT", WowTranslatorCheckButton8, "BOTTOMLEFT", 0, -20);
QTRCommandsLBL:SetFont(WT_Font, 12);
QTRCommandsLBL:SetText(QTR_Interface.commands);
  
end

local timer = CreateFrame("FRAME");

function QuestTradutor:wait(delay, func, arg1,arg2,arg3,arg4,arg5) 
   local endTime = GetTime() + delay;
	
	timer:SetScript("OnUpdate", function()
		if(endTime < GetTime()) then
			--time is up 
			func(arg1,arg2,arg3,arg4,arg5);
			timer:SetScript("OnUpdate", nil);
		end
	end);
end 

function QuestTradutor:ToggleQuestTranslate()
   if (curr_trans=="1") then
      curr_trans="0";
      QuestTradutor:Translate_Off(1);
   else   
      curr_trans="1";
      QuestTradutor:Translate_On(1);
   end
end 
 

function QuestTradutor:ToggleGossipTranslate()
   if (curr_goss=="1") then         -- wyłącz tłumaczenie - pokaż oryginalny tekst
      curr_goss="0";
      QuestTradutor:TranslateGossip_OFF();
   else                             -- pokaż tłumaczenie PL
      curr_goss="1";
      QuestTradutor:TranslateGossip_ON();
   end
end

function QuestTradutor:TranslateGossip_ON() 

   if(QuestTradutor:isImmersion()) then
      local Greeting_PL = GS_Gossip[curr_hash];
      ImmersionFrame.TalkBox.TextFrame.Text:SetText(QuestTradutor:ExpandUnitInfo(Greeting_PL)); 
      QTR_ToggleButtonGS4:SetText("Gossip-Hash=["..tostring(curr_hash).."] "..GS_lang);  
      
      local titleButton;
         for i = 1, ImmersionFrame.TitleButtons:GetNumActive(), 1 do 
            titleButton=ImmersionFrame.TitleButtons:GetButton(i);
            if (titleButton:GetText()) then
               Hash = StringHash(titleButton:GetText());
               if ( GS_Gossip[Hash] ) then   -- istnieje tłumaczenie tekstu dodatkowego
                  QTR_GS_MENUS[i] = titleButton:GetText(); -- gets original text from button
                  local fontf, fontsz = titleButton:GetFontString():GetFont();
                  titleButton:SetText(QuestTradutor:ExpandUnitInfo(GS_Gossip[Hash]));
                  titleButton:GetFontString():SetFont(fontf, fontsz); 
               end
            end
         end 
   else
      local Greeting_PL = GS_Gossip[curr_hash]; 
      GreetingText:SetText(QuestTradutor:ExpandUnitInfo(Greeting_PL));  
      GossipGreetingText:SetText(QuestTradutor:ExpandUnitInfo(Greeting_PL));   
      QTR_ToggleButtonGS:SetText("Gossip-Hash=["..tostring(curr_hash).."] "..GS_lang); 

      if (QuestTradutor:GetNumGossipOptions()>0) then    -- są jeszcze przyciski funkcji dodatkowych
         local pozycja=GetNumGossipActiveQuests()+GetNumGossipAvailableQuests()+1;
         local titleButton; 
         for i = 1, QuestTradutor:GetNumGossipOptions(), 1 do 
            titleButton=getglobal("GossipTitleButton"..tostring(pozycja+i)); 
            if (titleButton:GetText()) then
               Hash = StringHash(titleButton:GetText());
               if ( GS_Gossip[Hash] ) then   -- istnieje tłumaczenie tekstu dodatkowego
                  QTR_GS_MENUS[i] = titleButton:GetText(); -- gets original text from button 
                  titleButton:SetText(QuestTradutor:ExpandUnitInfo(GS_Gossip[Hash]));
                  titleButton:GetFontString():SetFont(QTR_Font2, 13); 
               end
            end
         end
      end
   end
end

function QuestTradutor:TranslateGossip_OFF()   
   if(QuestTradutor:isImmersion()) then
      ImmersionFrame.TalkBox.TextFrame.Text:SetText(QTR_GS[curr_hash]);    
      QTR_ToggleButtonGS4:SetText("Gossip-Hash=["..tostring(curr_hash).."] EN");  

         local titleButton; 
         for i = 1, ImmersionFrame.TitleButtons:GetNumActive(), 1 do 
            titleButton=ImmersionFrame.TitleButtons:GetButton(i);
            if (titleButton:GetText()) then  
               if ( QTR_GS_MENUS[i] ) then   -- istnieje tłumaczenie tekstu dodatkowego 
                  local fontf, fontsz = titleButton:GetFontString():GetFont();
                  titleButton:SetText(QTR_GS_MENUS[i]);
                  titleButton:GetFontString():SetFont(fontf, fontsz); 
               end
            end
         end
         QTR_GS_MENUS = {}; -- clear the array 
   else 
      GreetingText:SetText(QTR_GS[curr_hash]);  
      GossipGreetingText:SetText(QTR_GS[curr_hash]);   
      QTR_ToggleButtonGS:SetText("Gossip-Hash=["..tostring(curr_hash).."] EN"); 

      if (QuestTradutor:GetNumGossipOptions()>0) then    -- są jeszcze przyciski funkcji dodatkowych
         local pozycja=GetNumGossipActiveQuests()+GetNumGossipAvailableQuests()+1;
         local titleButton; 
         for i = 1, QuestTradutor:GetNumGossipOptions(), 1 do 
            titleButton=getglobal("GossipTitleButton"..tostring(pozycja+i)); 
            if (titleButton:GetText()) then  
               if ( QTR_GS_MENUS[i] ) then   -- istnieje tłumaczenie tekstu dodatkowego 
                  titleButton:SetText(QTR_GS_MENUS[i]);
                  titleButton:GetFontString():SetFont(QTR_Font2, 13); 
               end
            end
         end
         QTR_GS_MENUS = {}; -- clear the array
      end
   end
end


function QuestTradutor:LoadUIElements() 

   -- przycisk z nr ID questu w QuestFrame (NPC)
   QTR_ToggleButton0 = CreateFrame("Button",nil, QuestFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton0:SetWidth(150);
   QTR_ToggleButton0:SetHeight(20);
   QTR_ToggleButton0:SetText("Quest ID=?");
   QTR_ToggleButton0:Show();
   QTR_ToggleButton0:ClearAllPoints();
   QTR_ToggleButton0:SetPoint("TOPLEFT", QuestFrame, "TOPLEFT", 115, -50);
   QTR_ToggleButton0:SetScript("OnClick", QuestTradutor.ToggleQuestTranslate);
   
   -- przycisk z nr ID questu w QuestFrameProgressPanel
   QTR_ToggleButton1 = CreateFrame("Button",nil, QuestLogFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton1:SetWidth(150);
   QTR_ToggleButton1:SetHeight(18);
   QTR_ToggleButton1:SetText("Quest ID=?");
   QTR_ToggleButton1:Show();
   QTR_ToggleButton1:ClearAllPoints();
   QTR_ToggleButton1:GetFontString():SetPoint("CENTER", 0, 1);
   QTR_ToggleButton1:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", 178, -42);
   QTR_ToggleButton1:SetScript("OnClick", QuestTradutor.ToggleQuestTranslate); 

   -- QuestLogDetailFrame
   QTR_ToggleButton2 = CreateFrame("Button",nil, QuestLogDetailFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton2:SetWidth(135);
   QTR_ToggleButton2:SetHeight(20);
   QTR_ToggleButton2:SetText("Quest ID=?");
   if(QuestTradutor.target > 2) then 
      QTR_ToggleButton2:Show();
   else
      QTR_ToggleButton2:Hide();
   end
   QTR_ToggleButton2:ClearAllPoints();
   QTR_ToggleButton2:SetPoint("TOPLEFT", QuestLogDetailFrame, "TOPLEFT", 70, -45);
   QTR_ToggleButton2:SetScript("OnClick", QuestTradutor.ToggleQuestTranslate);

   QTR_ToggleButtonWM = CreateFrame("Button",nil, WorldMapQuestDetailScrollFrame, "UIPanelButtonTemplate");
   QTR_ToggleButtonWM:SetWidth(135);
   QTR_ToggleButtonWM:SetHeight(17);
   QTR_ToggleButtonWM:SetText("Quest ID=?"); 
   if(QuestTradutor.target > 2) then 
      QTR_ToggleButtonWM:Show();
   else
      QTR_ToggleButtonWM:Hide();
   end 
   QTR_ToggleButtonWM:ClearAllPoints();
   QTR_ToggleButtonWM:SetPoint("BOTTOMRIGHT", WorldMapQuestDetailScrollFrame, "BOTTOMRIGHT", 0, -21);
   QTR_ToggleButtonWM:SetScript("OnClick", QuestTradutor.ToggleQuestTranslate);

 

   -- przycisk z nr HASH gossip w QuestMapDetailsScrollFrame 

   QTR_ToggleButtonGS = CreateFrame("Button",nil, GossipFrameGreetingPanel, "UIPanelButtonTemplate");
   QTR_ToggleButtonGS:SetWidth(220);
   QTR_ToggleButtonGS:SetHeight(20);
   QTR_ToggleButtonGS:SetText("Gossip-Hash=?");
   QTR_ToggleButtonGS:Show(); 
   QTR_ToggleButtonGS:ClearAllPoints();
   QTR_ToggleButtonGS:SetPoint("TOPLEFT", GossipFrameGreetingPanel, "TOPLEFT", 90, -50);
   QTR_ToggleButtonGS:SetScript("OnClick", QuestTradutor.ToggleGossipTranslate);

   -- funkcja wywoływana po kliknięciu na nazwę questu w QuestLog

   if(QuestTradutor.target > 1) then 
      QuestLogDetailScrollFrame:HookScript( "OnShow", QuestTradutor.Prepare1sek);
      EmptyQuestLogFrame:HookScript("OnShow", QuestTradutor.EmptyQuestLog); 
      hooksecurefunc("SelectQuestLogEntry", QuestTradutor.Prepare1sek);
      if(QuestTradutor.target > 2) then
         hooksecurefunc("WorldMapFrame_SelectQuestFrame", QuestTradutor.SelectedMapQuest); -- needed for worldmapquest handling
      end 
   else  
      c_HookScript(QuestLogDetailScrollFrame, "OnShow", QuestTradutor.Prepare1sek);
      c_HookScript(EmptyQuestLogFrame,"OnShow", QuestTradutor.EmptyQuestLog); 
      c_hooksecurefunc("SelectQuestLogEntry", QuestTradutor.Prepare1sek);
   end


   QuestTradutor:isQuestGuru();
   QuestTradutor:isImmersion();
   QuestTradutor:isStoryline();
end

function QuestTradutor:SetupGSButton(isQuestGreeting) 
   if(isQuestGreeting == true) then 
      QTR_ToggleButtonGS:SetParent(QuestFrame);
      QTR_ToggleButtonGS:SetPoint("TOPLEFT", QuestFrame, "TOPLEFT", 90, -50);  
   else
      QTR_ToggleButtonGS:SetParent(GossipFrameGreetingPanel); 
      QTR_ToggleButtonGS:SetPoint("TOPLEFT", GossipFrameGreetingPanel, "TOPLEFT", 90, -50); 
   end
end

function QuestTradutor:SelectedMapQuest(questFrame) 
   QuestTradutor:QuestPrepare("WORLDMAP_SELECTED_QUEST");
end   

function QuestTradutor:splitstr (str, inSplitPattern, outResults )
   if not outResults then
     outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
   while theSplitStart do
     table.insert( outResults, string.sub( str, theStart, theSplitStart-1 ) )
     theStart = theSplitEnd + 1
     theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( str, theStart ) )
   return outResults
end
 

function QuestTradutor:IsQuestAvailableForPlayerRace(questId)
   if(QuestTranslator_QuestRaceList[questId]) then
      local bs = QuestTranslator_QuestRaceList[questId];
      local playerRace, playerRaceEn = UnitRace("player");

      if(bs == "0" or bs == "1791") then
         return true; -- the quest is available for all races...
      end  

      if(QuestTranslator_PlayerRaceList[tostring(playerRaceEn)]) then
         local qtr_raceInfo =  QuestTradutor:splitstr(QuestTranslator_PlayerRaceList[tostring(playerRaceEn)], ","); 
         local raceId = qtr_raceInfo[1];
         local IsHorde = qtr_raceInfo[2]; 

         if(bs == raceId) then
            return true;
         end

         if(bs == "690") then  -- 690 means the quest is available for all horde races
            if(IsHorde == "true") then
               return true;
            end
         end  
         
         if(bs == "1101") then -- 1101 means the quest is available for all alliance races
            if(IsHorde == "false") then
               return true;
            end
         end
      end

   end

   return false;
      
end

function QuestTradutor:isQuestFromTargetNPC(questId, targetNPC) 
   if (QuestTranslator_QuestGiverList[tostring(targetNPC)]) then
      local q_lists=QuestTranslator_QuestGiverList[tostring(targetNPC)];
      q_i=string.find(q_lists, ",");
      if ( string.find(q_lists, ",")==nil ) then
         -- only 1 questID to this npcID
         quest_ID=tonumber(q_lists);
         if(tonumber(questId) == quest_ID) then
            return true;
         else
            return false;
         end
      else
         local QTR_table=QuestTradutor:splitqinfo(q_lists, ",", -1);
         for ii,vv in ipairs(QTR_table) do
            if(tonumber(vv) == tonumber(questId)) then
               return true;
            end
         end
      end 
   end
   return false;
end

function QuestTradutor:splitqinfo(str, c, t) 
   local aCount = 0;
   local array = {};
   local a = string.find(str, c);
   while a do
      if(t == -1) then
         if(QuestTradutor:IsQuestAvailableForPlayerRace(string.sub(str, 1, a-1))) then 
            aCount = aCount + 1;
            array[aCount] = string.sub(str, 1, a-1); 
         end
      else
         if(QuestTradutor:isQuestFromTargetNPC(string.sub(str, 1, a-1), t)) then
            if(QuestTradutor:IsQuestAvailableForPlayerRace(string.sub(str, 1, a-1))) then 
                  aCount = aCount + 1;
                  array[aCount] = string.sub(str, 1, a-1); 
            end
         end
      end 

      str=string.sub(str, a+1);
      a = string.find(str, c);
   end

   if(t == -1) then
      if(QuestTradutor:IsQuestAvailableForPlayerRace(str)) then 
         aCount = aCount + 1;
         array[aCount] = str; 
      end
   else
      if(QuestTradutor:isQuestFromTargetNPC(str, t)) then
         if(QuestTradutor:IsQuestAvailableForPlayerRace(str)) then 
               aCount = aCount + 1;
               array[aCount] = str; 
         end
      end
   end

   return array;
 end
 
function QuestTradutor:isQuestGuru() 
   if (QuestGuru ~= nil ) then
      if (QTR_ToggleButton3==nil) then
         -- przycisk z nr ID questu w QuestGuru
         QTR_ToggleButton3 = CreateFrame("Button",nil, QuestGuru, "UIPanelButtonTemplate");
         QTR_ToggleButton3:SetWidth(150);
         QTR_ToggleButton3:SetHeight(20);
         QTR_ToggleButton3:SetText("Quest ID=?");
         QTR_ToggleButton3:Show();
         QTR_ToggleButton3:ClearAllPoints();
         QTR_ToggleButton3:SetPoint("TOPLEFT", QuestGuru, "TOPLEFT", 330, -33);
         QTR_ToggleButton3:SetScript("OnClick", QuestTradutor.ToggleQuestTranslate);
         -- uaktualniono dane w QuestLogu
         if(QuestTradutor.target > 1) then
            QuestGuru:HookScript("OnUpdate", function() QuestTradutor:PrepareReload() end);
         else
            c_HookScript(QuestGuru, "OnUpdate", function() QuestTradutor:PrepareReload() end);
         end

      end
      return true;
   else
      return false;   
   end
end


function QuestTradutor:isImmersion() 
   if (ImmersionFrame ~= nil ) then
      if (QTR_ToggleButton4==nil and QTR_ToggleButtonGS4 == nil) then
         -- przycisk z nr ID questu
         QTR_ToggleButton4 = CreateFrame("Button",nil, ImmersionFrame.TalkBox, "UIPanelButtonTemplate");
         QTR_ToggleButton4:SetWidth(150);
         QTR_ToggleButton4:SetHeight(20);
         QTR_ToggleButton4:SetText("Quest ID=?");
         QTR_ToggleButton4:Show();
         QTR_ToggleButton4:ClearAllPoints();
         QTR_ToggleButton4:SetPoint("TOPLEFT", ImmersionFrame.TalkBox, "TOPRIGHT", -200, -116);
         QTR_ToggleButton4:SetScript("OnClick", QuestTradutor.ToggleQuestTranslate);
         -- otworzono okno dodatku Immersion : wywołanie przez OnEvent
         if(QuestTradutor.target > 1) then
            ImmersionFrame.TalkBox:HookScript("OnHide",function() QTR_ToggleButton4:Hide(); end);
         else 
            c_HookScript(ImmersionFrame.TalkBox, "OnHide",function() QTR_ToggleButton4:Hide(); end);
         end

         QTR_ToggleButton4:Disable();     -- nie można na razie przyciskać
         QTR_ToggleButton4:Hide();        -- wstępnie przycisk niewidoczny (bo może jest wybór questów)

         QTR_ToggleButtonGS4 = CreateFrame("Button",nil, ImmersionFrame.TalkBox, "UIPanelButtonTemplate");
         QTR_ToggleButtonGS4:SetWidth(220);
         QTR_ToggleButtonGS4:SetHeight(20);
         QTR_ToggleButtonGS4:SetText("Quest ID=?");
         QTR_ToggleButtonGS4:Show();
         QTR_ToggleButtonGS4:ClearAllPoints();
         QTR_ToggleButtonGS4:SetPoint("TOPLEFT", ImmersionFrame.TalkBox, "TOPRIGHT", -270, -116);
         QTR_ToggleButtonGS4:SetScript("OnClick", QuestTradutor.ToggleGossipTranslate);
         -- otworzono okno dodatku Immersion : wywołanie przez OnEvent
         if(QuestTradutor.target > 1) then
            ImmersionFrame.TalkBox:HookScript("OnHide",function() QTR_ToggleButtonGS4:Hide(); end);
         else
            c_HookScript(ImmersionFrame.TalkBox,"OnHide",function() QTR_ToggleButtonGS4:Hide(); end);
         end

         QTR_ToggleButtonGS4:Disable();     -- nie można na razie przyciskać
         QTR_ToggleButtonGS4:Hide();        -- wstępnie przycisk niewidoczny (bo może jest wybór questów)
      end
      return true;
   else   
      return false;
   end
end
   

function QuestTradutor:isStoryline() 
if (Storyline_NPCFrame ~= nil ) then
      if (QTR_ToggleButton5==nil) then
         -- przycisk z nr ID questu
         QTR_ToggleButton5 = CreateFrame("Button",nil, Storyline_NPCFrameChat, "UIPanelButtonTemplate");
         QTR_ToggleButton5:SetWidth(150);
         QTR_ToggleButton5:SetHeight(20);
         QTR_ToggleButton5:SetText("Quest ID=?");
         QTR_ToggleButton5:Hide();
         QTR_ToggleButton5:ClearAllPoints();
         QTR_ToggleButton5:SetPoint("BOTTOMLEFT", Storyline_NPCFrameChat, "BOTTOMLEFT", 244, -16);
         QTR_ToggleButton5:SetScript("OnClick", QuestTradutor.ToggleQuestTranslate);
         if(QuestTradutor.target > 1) then
            Storyline_NPCFrameObjectivesContent:HookScript("OnShow", function() QuestTradutor:Storyline_Objectives() end);
            Storyline_NPCFrameRewards:HookScript("OnShow", function() QuestTradutor:Storyline_Rewards() end);
            Storyline_NPCFrameChat:HookScript("OnHide", function() QuestTradutor:Storyline_Hide() end);
         else
            c_HookScript(Storyline_NPCFrameObjectivesContent,"OnShow", function() QuestTradutor:Storyline_Objectives() end);
            c_HookScript(Storyline_NPCFrameRewards,"OnShow", function() QuestTradutor:Storyline_Rewards() end);
            c_HookScript(Storyline_NPCFrameChat,"OnHide", function() QuestTradutor:Storyline_Hide() end); 
         end
--         QTR_ToggleButton5:Disable();     -- nie można przyciskać
      end 
      return true;
   else
      return false;
   end
end

function QuestTradutor:GetQuestID(titleText) 

   local q_title = GetTitleText();  
   local q_i = 1;
   quest_ID = 0; 

   if(titleText) then
      q_title = titleText
   end 
   
   if ( quest_ID==0 or quest_ID==nil) then
      -- search in QuestLog 
      if(QuestTradutor.target > 2) then
         while GetQuestLogTitle(q_i) do
            local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(q_i)
            if ( not isHeader ) then
               if ( q_title == questTitle ) then 
                  quest_ID=questID;
                  break;
               end
             end
            q_i = q_i + 1;
         end
      else
         local index = 1  
         while GetQuestLogTitle(index) do
            local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(index)
            if ( not isHeader ) then 
               if ( q_title == questTitle ) then 
                  return QuestTradutor:GetQuestIDFromQuestLog(q_title, index, QTR_name, QTR_race, QTR_class) 
               end
             end
            index = index + 1;
         end
      end
   end

   
   if ( q_title == nil or q_title == "") then 
      q_title = GetQuestLogTitle(GetQuestLogSelection()) 
   end

   if ( quest_ID == 0 or quest_ID==nil) then
      if ( isGetQuestID=="1" ) then
         quest_ID = GetQuestID();
      end
      if ( quest_ID == 0 ) then
         if (QuestTranslator_QuestList[q_title]) then
            local q_lists=QuestTranslator_QuestList[q_title];
            q_i=string.find(q_lists, ","); 
            if ( string.find(q_lists, ",")==nil ) then
               -- only 1 questID to this title
               quest_ID=tonumber(q_lists); 
            else
               -- multiple questIDs - get first, available (not completed) questID from QuestLists and which the NPC is in the target from QuestGiverList
               
               -- get target NPC id 
                  local targetNPC = 0;

                  if(UnitName("target") == nil or UnitName("target") == "") then
                     targetNPC = -1;
                  else
                     targetNPC = UnitName('target')
                  end 

                  local QTR_table=QuestTradutor:splitqinfo(q_lists, ",", targetNPC);
               
                  if(QTR_table == nil) then
                     return 0;
                  end

                  local QTR_multiple = "";
                  local QTR_Center=""; 

                  for ii,vv in ipairs(QTR_table) do 
                     if (QuestTranslator_QuestMatch[tonumber(vv)]) then
                        local origQuestText = GetQuestText();
                        if (origQuestText == "" or origQuestText == nil) then origQuestText = GetQuestLogQuestText() end
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
      end 
   return (quest_ID);
end  

function QuestTradutor:GameTooltipHooks()
   if(QuestTradutor.target > 2) then
      GameTooltip:HookScript("OnShow", QuestTradutor.ToolTipTranslator_ShowTranslationG);
      GameTooltip:HookScript("OnHide", QuestTradutor.ToolTipTranslator_ResetChangedTooltipValues); 

      --ItemRefTooltip:HookScript("OnShow", QTRToolTipTranslator_ShowTranslationR);
      ItemRefTooltip:HookScript("OnHide", QuestTradutor.ToolTipTranslator_ResetChangedTooltipValues);
      hooksecurefunc("SetItemRef", QuestTradutor.ToolTipTranslator_ShowTranslationR)

      if(AtlasLootTooltip) then
         AtlasLootTooltip:HookScript("OnShow", QuestTradutor.ToolTipTranslator_ShowTranslationA);
         AtlasLootTooltip:HookScript("OnHide", QuestTradutor.ToolTipTranslator_ResetChangedTooltipValues); 
      end

      for i = 1, 2, 1 do -- i think max 2 of those are shown
         if _G["ShoppingTooltip"..i] then
            _G["ShoppingTooltip"..i]:HookScript("OnShow", function() QuestTradutor:ToolTipTranslator_ShowTranslationS(i) end);
            _G["ShoppingTooltip"..i]:HookScript("OnHide", QuestTradutor.ToolTipTranslator_ResetChangedTooltipValues);
         end
      end  
   else
      c_HookScript(GameTooltip,"OnShow", QuestTradutor.ToolTipTranslator_ShowTranslationG);
      c_HookScript(GameTooltip,"OnHide", QuestTradutor.ToolTipTranslator_ResetChangedTooltipValues); 

      --ItemRefTooltip:HookScript("OnShow", QTRToolTipTranslator_ShowTranslationR);
      c_HookScript(ItemRefTooltip, "OnHide", QuestTradutor.ToolTipTranslator_ResetChangedTooltipValues);
      if(QuestTradutor.target < 2) then
         c_hooksecurefunc("SetItemRef", QuestTradutor.ToolTipTranslator_ShowTranslationR)
      else
         hooksecurefunc("SetItemRef", QuestTradutor.ToolTipTranslator_ShowTranslationR)
      end


      if(AtlasLootTooltip) then
         c_HookScript(AtlasLootTooltip,"OnShow", QuestTradutor.ToolTipTranslator_ShowTranslationA);
         c_HookScript(AtlasLootTooltip,"OnHide", QuestTradutor.ToolTipTranslator_ResetChangedTooltipValues); 
      end

      for i = 1, 2, 1 do -- i think max 2 of those are shown
         if _G["ShoppingTooltip"..i] then
            c_HookScript(_G["ShoppingTooltip"..i],"OnShow", function() QuestTradutor:ToolTipTranslator_ShowTranslationS(i) end);
            c_HookScript(_G["ShoppingTooltip"..i],"OnHide", QuestTradutor.ToolTipTranslator_ResetChangedTooltipValues);
         end
      end
   end
end


function QuestTradutor:SendChatAd(qName) 
   local now = GetTime(); 
   if (last_time + QTR_PS["period"]*60 < now) then  -- OK, czas wypisać reklamę
      if(qName) then
         if (tonumber(QTR_PS["channel"])>0) then
            SendChatMessage(string.gsub(QTR_Reklama.TEXT1, '%%s', qName),"CHANNEL",nil,tonumber(QTR_PS["channel"]));
         else
            SendChatMessage(string.gsub(QTR_Reklama.TEXT1, '%%s', qName),"SAY");
         end
         last_text = 1;
      else
         if (tonumber(QTR_PS["channel"])>0) then
            SendChatMessage(QTR_Reklama.TEXT2,"CHANNEL",nil,tonumber(QTR_PS["channel"]));
         else
            SendChatMessage(QTR_Reklama.TEXT2,"SAY");
         end
         last_text = 2;
      end   
   last_time = now;
   elseif(last_text == 0) then
      if(qName) then
         if (tonumber(QTR_PS["channel"])>0) then
            SendChatMessage(string.gsub(QTR_Reklama.TEXT1, '%%s', qName),"CHANNEL",nil,tonumber(QTR_PS["channel"]));
         else
            SendChatMessage(string.gsub(QTR_Reklama.TEXT1, '%%s', qName),"SAY");
         end
         last_text = 1;
      end
   end   
 end

-- Wywoływane przy przechwytywanych zdarzeniach
function QuestTradutor:OnEvent(self, event, name, arg1,arg2,arg3,arg4,arg5)  
   if (QTR_onDebug) then
      print('OnEvent-event: '..event);   
   end   
   if (event=="ADDON_LOADED" and arg1=="QuestTradutor") then 

      QuestTradutor:GameTooltipHooks();
      QuestTradutor:CheckVars();
      QuestTradutor:LoadUIElements();

      SlashCmdList["WOWPOPOLSKU_QUESTS"] = function(msg) QuestTradutor:SlashCommand(msg); end
      SLASH_WOWPOPOLSKU_QUESTS1 = "/questtradutor";
      SLASH_WOWPOPOLSKU_QUESTS2 = "/qtr";
      
      QuestTradutor:LoadOptionsFrame();
      -- twórz interface Options w Blizzard-Interface-Addons 
      print ("|cffffff00QuestTradutor ver. "..QTR_version.." - "..QTR_Messages.loaded);
      QuestTradutor:UnregisterEvent("ADDON_LOADED");
      QuestTradutor.ADDON_LOADED = nil; 
      
      if(QTR_PS["enablegoss"]=="1") then
         QTR_ToggleButtonGS:Show();
      else
         QTR_ToggleButtonGS:Hide();
      end 

   elseif (event=="QUEST_DETAIL" or event=="QUEST_PROGRESS" or event=="QUEST_COMPLETE") then   
      QTR_ToggleButtonGS:Hide();
      QTR_ToggleButton0:Show();
      if ( QuestFrame:IsVisible() or QuestTradutor:isImmersion()) then 
         QuestTradutor:wait(0.1, QuestTradutor.QuestPrepare, self, event); 
      elseif (QuestTradutor:isStoryline()) then
         if (not QuestTradutor:wait(1,QuestTradutor.Storyline_Quest)) then
         -- opóźnienie 1 sek
         end
      end	-- QuestFrame is Visible 
   elseif (event=="GOSSIP_SHOW" or event=="QUEST_GREETING") then   
      QTR_ToggleButtonGS:Show();
      QTR_ToggleButton0:Hide();
      if(QTR_PS["enablegoss"]=="1") then
         QuestTradutor:Gossip_Show();
      end
   elseif (QuestTradutor:isImmersion() and event=="QUEST_LOG_UPDATE") then
      QuestTradutor:delayed3();
   elseif (event=="QUEST_LOG_UPDATE") then
     if(QuestTradutor.target < 2) then
        QuestTradutor:CheckQuestLog();
     end
   elseif (event=="QUEST_ACCEPTED") then
      if(QuestTradutor.target > 1) then
         SelectQuestLogEntry(arg1); 
         local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(GetQuestLogSelection()); 

         if(not (questID == 0)) then  
            if (QTR_PS["reklama"]=="1") then
               QuestTradutor:SendChatAd(questTitle);
            end 
         else
            if (QTR_PS["reklama"]=="1") then
               QuestTradutor:SendChatAd(nil);
            end
         end
      end 
   end  
end

function QuestTradutor:UpdateGameClientCache()  
   local id = 1; 
   QTR_QuestCache = {} 
   local qc = 0; 
   local nEntry, nQuests = GetNumQuestLogEntries();
   while qc < nQuests do
      local questName, level, _, isHeader, isCollapsed, _ = GetQuestLogTitle(id);
      if not isHeader and not isCollapsed then
         SelectQuestLogEntry(id);
         local questText, objectiveText = GetQuestLogQuestText();
         local hash = StringHash(questName..level..objectiveText); 

         QTR_QuestCache[hash] = questName; 
      end
        if not isHeader then
            qc = qc + 1;
        end
        id = id + 1;
   end   
end
 
function QuestTradutor:CheckQuestLog()
   local function map_length(t)
      local c = 0
      for k, v in pairs(t) do
           c = c + 1
      end
      return c
   end

   if(not QTR_QuestCache) then
      QTR_QuestCache = {} 
      QuestTradutor:UpdateGameClientCache();
      QTR_OldQuestCache = QTR_QuestCache;
   else
      QuestTradutor:UpdateGameClientCache(); 
      if(map_length(QTR_QuestCache) > map_length(QTR_OldQuestCache)) then
         for k,v in pairs(QTR_QuestCache) do 
            if(not QTR_OldQuestCache[k]) then
               if (QTR_PS["reklama"]=="1") then
                  QuestTradutor:SendChatAd(QTR_QuestCache[k]);
               end
            end
         end
      end 

      QTR_OldQuestCache = QTR_QuestCache;
   end
end

function QuestTradutor:GetQuestData(ID, FIELD)
   return QTR_QuestData[ID][FIELD]; 
end



function QuestTradutor:Immersion_GOSSIP()
   local Greeting_Text = ImmersionFrame.TalkBox.TextFrame.Text.storedText;
   Nazwa_NPC = GetUnitName('npc'); 

   if (string.find(Greeting_Text," ")==nil) then         -- nie jest to tekst po polsku (nie ma twardej spacji)
      Nazwa_NPC = string.gsub(Nazwa_NPC, '"', '\"');
      Greeting_Text = string.gsub(Greeting_Text, '"', '\"');
      local Czysty_Text = string.gsub(Greeting_Text, '\r', '');
      Czysty_Text = string.gsub(Czysty_Text, '\n', '$B');
      Czysty_Text = string.gsub(Czysty_Text, QTR_name, '$N');
      Czysty_Text = string.gsub(Czysty_Text, string.upper(QTR_name), '$N$');
      Czysty_Text = string.gsub(Czysty_Text, QTR_race, '$R');
      Czysty_Text = string.gsub(Czysty_Text, string.lower(QTR_race), '$R');
      Czysty_Text = string.gsub(Czysty_Text, QTR_class, '$C');
      Czysty_Text = string.gsub(Czysty_Text, string.lower(QTR_class), '$C');
      Czysty_Text = string.gsub(Czysty_Text, '$N$', '');
      Czysty_Text = string.gsub(Czysty_Text, '$N', '');
      Czysty_Text = string.gsub(Czysty_Text, '$B', '');
      Czysty_Text = string.gsub(Czysty_Text, '$R', '');
      Czysty_Text = string.gsub(Czysty_Text, '$C', ''); 
      local Hash = StringHash(Czysty_Text); 
      curr_hash = Hash;
      QTR_GS[Hash] = Greeting_Text;                      -- zapis oryginalnego tekstu
      if ( GS_Gossip[Hash] ) then   -- istnieje tłumaczenie tekstu GOSSIP tego NPC
         curr_goss = "1";
         local Greeting_PL = GS_Gossip[Hash];  
         ImmersionFrame.TalkBox.TextFrame.Text:SetText(QuestTradutor:ExpandUnitInfo(Greeting_PL)); 
         QTR_ToggleButtonGS4:SetText("Gossip-Hash=["..tostring(Hash).."] "..GS_lang);
         QTR_ToggleButtonGS4:Enable();
         QTR_ToggleButtonGS4:Show();
         QTR_ToggleButton4:Hide(); 
      else                               -- nie ma tłumaczenia w bazie GOSSIP
         curr_goss = "0"; 
         QTR_ToggleButtonGS4:SetText("Gossip-Hash=["..tostring(Hash).."] "..GS_lang);
         QTR_ToggleButtonGS4:Disable();
         QTR_ToggleButtonGS4:Show();
         QTR_ToggleButton4:Hide(); 
      end

      local titleButton; 
      for i = 1, ImmersionFrame.TitleButtons:GetNumActive(), 1 do 
         titleButton=ImmersionFrame.TitleButtons:GetButton(i);
         if (titleButton:GetText()) then 
            Hash = StringHash(titleButton:GetText());
            if ( GS_Gossip[Hash] ) then   -- istnieje tłumaczenie tekstu dodatkowego
               QTR_GS_MENUS[i] = titleButton:GetText(); -- gets and saves original text from button
               local fontf, fontsz = titleButton:GetFontString():GetFont();
               titleButton:SetText(QuestTradutor:ExpandUnitInfo(GS_Gossip[Hash]));
               titleButton:GetFontString():SetFont(fontf, fontsz);
            end
         end
      end
   end
end


-- Otworzono okienko rozmowy z NPC
function QuestTradutor:Gossip_Show()
   QTR_GS_MENUS = {}; -- clear the menu array 

   if(QuestTradutor:isImmersion()) then
      QuestTradutor:wait(0.2, QuestTradutor.Immersion_GOSSIP); -- need to wait ImmersionFrame things load.
      return;
   end

   local Nazwa_NPC = GossipFrameNpcNameText:GetText();   
   
   if(Nazwa_NPC ~= GetUnitName('npc')) then
      Nazwa_NPC = nil; 
   end

   curr_hash = 0;
   if (Nazwa_NPC) then
      QuestTradutor:SetupGSButton(false);
      local Greeting_Text = GossipGreetingText:GetText(); 
      if (string.find(Greeting_Text," ")==nil) then         -- nie jest to tekst po polsku (nie ma twardej spacji)
         Nazwa_NPC = string.gsub(Nazwa_NPC, '"', '\"');
         Greeting_Text = string.gsub(Greeting_Text, '"', '\"');
         local Czysty_Text = string.gsub(Greeting_Text, '\r', '');
         Czysty_Text = string.gsub(Czysty_Text, '\n', '$B');
         Czysty_Text = string.gsub(Czysty_Text, QTR_name, '$N');
         Czysty_Text = string.gsub(Czysty_Text, string.upper(QTR_name), '$N$');
         Czysty_Text = string.gsub(Czysty_Text, QTR_race, '$R');
         Czysty_Text = string.gsub(Czysty_Text, string.lower(QTR_race), '$R');
         Czysty_Text = string.gsub(Czysty_Text, QTR_class, '$C');
         Czysty_Text = string.gsub(Czysty_Text, string.lower(QTR_class), '$C');
         Czysty_Text = string.gsub(Czysty_Text, '$N$', '');
         Czysty_Text = string.gsub(Czysty_Text, '$N', '');
         Czysty_Text = string.gsub(Czysty_Text, '$B', '');
         Czysty_Text = string.gsub(Czysty_Text, '$R', '');
         Czysty_Text = string.gsub(Czysty_Text, '$C', ''); 
         local Hash = StringHash(Czysty_Text); 
         curr_hash = Hash;
         QTR_GS[Hash] = Greeting_Text;                      -- zapis oryginalnego tekstu
         if ( GS_Gossip[Hash] ) then   -- istnieje tłumaczenie tekstu GOSSIP tego NPC
            curr_goss = "1";
            local Greeting_PL = GS_Gossip[Hash];
            GossipGreetingText:SetText(QuestTradutor:ExpandUnitInfo(Greeting_PL)); 
            QTR_ToggleButtonGS:SetText("Gossip-Hash=["..tostring(Hash).."] "..GS_lang);
            QTR_ToggleButtonGS:Enable(); 
            QTR_ToggleButtonGS:Show()
         else                               -- nie ma tłumaczenia w bazie GOSSIP
            curr_goss = "0";
            QTR_ToggleButtonGS:SetText("Gossip-Hash=["..tostring(Hash).."] EN");
            QTR_ToggleButtonGS:Disable(); 
            QTR_ToggleButtonGS:Show()
         end
         if (QuestTradutor:GetNumGossipOptions()>0) then    -- są jeszcze przyciski funkcji dodatkowych 
            local pozycja=QuestTradutor:GetNumGossipActiveQuests()+QuestTradutor:GetNumGossipAvailableQuests();
            if pozycja > 0 then pozycja = pozycja+1 end
            local titleButton;
            for i = 1, QuestTradutor:GetNumGossipOptions(), 1 do 
               titleButton=getglobal("GossipTitleButton"..tostring(pozycja+i));
               if (titleButton:GetText()) then 
                  Hash = StringHash(titleButton:GetText());
                  if ( GS_Gossip[Hash] ) then   -- istnieje tłumaczenie tekstu dodatkowego
                     QTR_GS_MENUS[i] = titleButton:GetText(); -- gets and saves original text from button
                     titleButton:SetText(QuestTradutor:ExpandUnitInfo(GS_Gossip[Hash]));
                     titleButton:GetFontString():SetFont(QTR_Font2, 13); 
                  end
               end
            end
         end
      end
   elseif (GetGreetingText() ~= nil or GetGreetingText() ~= "" and Nazwa_NPC ~= (GetUnitName('npc')) ) then  
         QuestTradutor:SetupGSButton(true);
         QTR_ToggleButton0:Hide(); -- hide translate quest button 
         local Greeting_Text = GetGreetingText(); 
         Nazwa_NPC = GetUnitName('npc');

         if(Nazwa_NPC == nil) then return end
   
         if (string.find(Greeting_Text," ")==nil) then         -- nie jest to tekst po polsku (nie ma twardej spacji)
            Nazwa_NPC = string.gsub(Nazwa_NPC, '"', '\"');
            Greeting_Text = string.gsub(Greeting_Text, '"', '\"');
            local Czysty_Text = string.gsub(Greeting_Text, '\r', '');
            Czysty_Text = string.gsub(Czysty_Text, '\n', '$B');
            Czysty_Text = string.gsub(Czysty_Text, QTR_name, '$N');
            Czysty_Text = string.gsub(Czysty_Text, string.upper(QTR_name), '$N$');
            Czysty_Text = string.gsub(Czysty_Text, QTR_race, '$R');
            Czysty_Text = string.gsub(Czysty_Text, string.lower(QTR_race), '$R');
            Czysty_Text = string.gsub(Czysty_Text, QTR_class, '$C');
            Czysty_Text = string.gsub(Czysty_Text, string.lower(QTR_class), '$C');
            Czysty_Text = string.gsub(Czysty_Text, '$N$', '');
            Czysty_Text = string.gsub(Czysty_Text, '$N', '');
            Czysty_Text = string.gsub(Czysty_Text, '$B', '');
            Czysty_Text = string.gsub(Czysty_Text, '$R', '');
            Czysty_Text = string.gsub(Czysty_Text, '$C', ''); 
            local Hash = StringHash(Czysty_Text); 
            curr_hash = Hash;
            QTR_GS[Hash] = Greeting_Text;                      -- zapis oryginalnego tekstu
            if ( GS_Gossip[Hash] ) then   -- istnieje tłumaczenie tekstu GOSSIP tego NPC
               curr_goss = "1";
               local Greeting_PL = GS_Gossip[Hash];
               GreetingText:SetText(QuestTradutor:ExpandUnitInfo(Greeting_PL)); 
               QTR_ToggleButtonGS:SetText("Gossip-Hash=["..tostring(Hash).."] "..GS_lang);
               QTR_ToggleButtonGS:Enable(); 
               QTR_ToggleButtonGS:Show()
            else                               -- nie ma tłumaczenia w bazie GOSSIP
               curr_goss = "0";
               -- zapis do pliku
               QTR_ToggleButtonGS:SetText("Gossip-Hash=["..tostring(Hash).."] EN");
               QTR_ToggleButtonGS:Disable(); 
               QTR_ToggleButtonGS:Show()
            end
         end
   end
end


-- Otworzono pusty QuestLog
function QuestTradutor:EmptyQuestLog()
   QTR_ToggleButton1:Hide();
end
 
-- Otworzono okienko QuestLogFrame lub QuestMapDetailsScrollFrame lub QuestGuru lub Immersion
function QuestTradutor:QuestPrepare(zdarzeniere)

   local zdarzenie = zdarzeniere;   
   
   QTR_ToggleButton1:Show();        -- Show, bo mógł być ukryty przy pustym QuestLogu 

   if(QuestTradutor.target < 3) then
      QTR_ToggleButton1:SetPoint("TOPLEFT", QuestLogFrame, "TOPRIGHT", -220, -15);
      QuestLogTitleText:SetPoint("TOPLEFT",-40,-16)
   end

   if (QuestTradutor:isQuestGuru()) then
      if (QTR_PS["other1"]=="0") then       -- jest aktywny QuestGuru, ale nie zezwolono na tłumaczenie
         QTR_ToggleButton3:Hide();
         return;
      else   
         QTR_ToggleButton3:Show();
         if (QuestGuru:IsVisible() and (curr_trans=="0")) then
            QTR_Translate_Off(1);
            local questTitle, level, questTag, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(GetQuestLogSelection());
            if (QTR_quest_EN.id==questID) then
               return;
            end
         end
      end   
   end  

   
   if (QuestTradutor:isImmersion()) then
      if (QTR_PS["other2"]=="0") then       -- jest aktywny Immersion, ale nie zezwolono na tłumaczenie
         QTR_ToggleButton4:Hide();
         return
      else
         QTR_ToggleButton4:Show();
         if (ImmersionContentFrame:IsVisible() and (curr_trans=="0")) then
            QuestTradutor:Translate_Off(1);
            return;
         end
      end      
   end

   -- questlogdetailframe and questlogframe check, there are differences in the lua functions.

   if(zdarzenie == "WORLDMAP_SELECTED_QUEST") then
      if ((GetQuestLogTitle(GetQuestLogSelection()) == 0 or GetQuestLogTitle(GetQuestLogSelection()) == nil)) then
         if (QTR_onDebug) then
            print('GetQuestLogTItle null, qtr1');  
            return;
         end   
      else 
         local questTitleer, leveler, questTager, isHeaderer, isCollapseder, isCompleteer, isDailyer, Niller, questIDer = GetQuestLogTitle(GetQuestLogSelection());
         if (QTR_onDebug) then
            print('prntando questid do item selecionado: '..questTitleer);
            print(GetQuestLogTitle(GetQuestLogSelection()));
         end

         q_ID = questIDer; 
         str_ID = tostring(questIDer); 
         
         QTR_quest_EN.id = questIDer; 
         QTR_quest_LG.id = questIDer;  
      end  
   else  
      if(QuestTradutor.QuestLogDetailFrame:IsVisible() or QuestLogFrame:IsVisible() or WorldMapFrame:IsVisible()) then   
         if ((GetQuestLogTitle(GetQuestLogSelection()) == 0 or GetQuestLogTitle(GetQuestLogSelection()) == nil)) then
            if (QTR_onDebug) then
               print('GetQuestLogTItle null, qtr2');  
               return;
            end   
         else 
            local questTitleer, leveler, questTager, isHeaderer, isCollapseder, isCompleteer, isDailyer, Niller, questIDer = GetQuestLogTitle(GetQuestLogSelection());
            if(QuestTradutor.target < 3) then
               if(QuestTradutor:GetQuestID(questTitleer) == 0 or QuestTradutor:GetQuestID(questTitleer) == nil) then 
                  if(QTR_onDebug) then
                     print("GetQuestID on qtr3 returned 0 or nil");
                     print(zdarzenie);  
                  end 
               else   
                  q_ID = QuestTradutor:GetQuestID(questTitleer); 
                  str_ID = tostring(q_ID); 
            
                  QTR_quest_EN.id = q_ID; 
                  QTR_quest_LG.id = q_ID; 
                  zdarzenie = "QUEST_DETAIL_LOG"; -- just because of some functions...
               end
            else
               if (QTR_onDebug) then
                  print('prntando questid do item selecionado: '..questTitleer);
                  print(GetQuestLogTitle(GetQuestLogSelection()));
               end 
 
               q_ID = questIDer;
               str_ID = tostring(questIDer); 
            
               QTR_quest_EN.id = questIDer; 
               QTR_quest_LG.id = questIDer; 
               zdarzenie = "QUEST_DETAIL_LOG"; -- just because of some functions...
            end
         end  
      else 
         if(QuestTradutor:GetQuestID() == 0 or QuestTradutor:GetQuestID() == nil) then
            if(QTR_onDebug) then
               print("GetQuestID on qtr3 returned 0 or nil");
               print(zdarzenie);  
            end 
         else  
            q_ID = QuestTradutor:GetQuestID();
            str_ID = tostring(q_ID);
            QTR_quest_EN.id = q_ID; 
            QTR_quest_LG.id = q_ID;  
         end
      end
   end

   if(q_ID == 0 or q_ID == nil) then
      return; -- despite all efforts, no quest id so we won't continue.
   end
 
   if (QTR_PS["control"]=="1") then         -- zapisuj kontrolnie treść oryginalnych questów EN
      QTR_quest_EN.title = GetTitleText(); 
      if (QTR_quest_EN.title=="") then
         QTR_quest_EN.title=GetQuestLogTitle(GetQuestLogSelection());  
      end
      if (zdarzenie=="QUEST_DETAIL") then 
         QTR_quest_EN.details = GetQuestText();
         QTR_quest_EN.objectives = GetObjectiveText();
      end
      if (zdarzenie=="QUEST_DETAIL_LOG" or zdarzenie=="WORLDMAP_SELECTED_QUEST") then 
         QTR_quest_EN.title=GetQuestLogTitle(GetQuestLogSelection()); 
         local questDescription, questObjectives = GetQuestLogQuestText(); 
         QTR_quest_EN.details = questDescription;
         QTR_quest_EN.objectives = questObjectives; 
      end
      if (zdarzenie=="QUEST_PROGRESS") then 
         QTR_quest_EN.progress = GetProgressText(); 
      end
      if (zdarzenie=="QUEST_COMPLETE") then
         QTR_quest_EN.completion = GetRewardText(); 
         if(QTR_PLAYERQUESTS[QTR_quest_EN.id]) then  
            QTR_PLAYERQUESTS[QTR_quest_EN.id]["Completion"] = GetRewardText();
         end
      end
   end
   if ( QTR_PS["active"]=="1" ) then	-- tłumaczenia włączone
      QTR_ToggleButton0:Enable();
      QTR_ToggleButton1:Enable();
      QTR_ToggleButton2:Enable();
      QTR_ToggleButtonWM:Enable();  

      if (QuestTradutor:isImmersion()) then
         if (q_ID==0) then
            return;
         end   
         QTR_ToggleButton4:Enable();
      end
      curr_trans = "1";
      if ( QTR_QuestData[str_ID] or QTR_FIXEDQUEST[str_ID]) then   -- wyświetlaj tylko, gdy istnieje tłumaczenie
         if (QTR_onDebug) then
            print('Znalazł tłumaczenie dla ID: '..str_ID);   
         end   
         QTR_quest_LG.title = QuestTradutor:ExpandUnitInfo(QuestTradutor:GetQuestData(str_ID, "Title"));
         QTR_quest_EN.title = GetTitleText();
         if (QTR_quest_EN.title=="") then
            QTR_quest_EN.title=GetQuestLogTitle(GetQuestLogSelection()); 
         end
         QTR_quest_LG.details = QuestTradutor:ExpandUnitInfo(QuestTradutor:GetQuestData(str_ID, "Description"));
         QTR_quest_LG.objectives = QuestTradutor:ExpandUnitInfo(QuestTradutor:GetQuestData(str_ID, "Objectives"));
         if (zdarzenie=="QUEST_DETAIL") then
            QTR_quest_EN.details = GetQuestText();
            QTR_quest_EN.objectives = GetObjectiveText();
            QTR_quest_EN.itemchoose = QTR_MessOrig.itemchoose1;
            QTR_quest_LG.itemchoose = QTR_Messages.itemchoose1;
            QTR_quest_EN.itemreceive = QTR_MessOrig.itemreceiv1;
            QTR_quest_LG.itemreceive = QTR_Messages.itemreceiv1; 
            
            if (strlen(QTR_quest_EN.details)>0 and strlen(QTR_quest_LG.details)==0) then
               --QTR_MISSING[QTR_quest_EN.id.." DESCRIPTION"]=QTR_quest_EN.details;     -- save missing translation part
               if(QuestTradutor.target > 1) then
                  QTR_quest_LG.details = QTR_quest_EN.details .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing); 
               else
                  QTR_quest_LG.details = QTR_quest_EN.details .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing_v); 
               end
            end
            if (strlen(QTR_quest_EN.objectives)>0 and strlen(QTR_quest_LG.objectives)==0) then
               --QTR_MISSING[QTR_quest_EN.id.." OBJECTIVE"]=QTR_quest_EN.objectives;    -- save missing translation part
               
               if(QuestTradutor.target > 1) then
                  QTR_quest_LG.objectives = QTR_quest_EN.objectives .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing);
               else
                  QTR_quest_LG.objectives = QTR_quest_EN.objectives .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing_v);
               end
            end 
         else   
            if (QTR_quest_LG.details ~= GetQuestText()) then
               QTR_quest_EN.details =  GetQuestText();
            end
            if (QTR_quest_LG.objectives ~= GetObjectiveText()) then
               QTR_quest_EN.objectives = GetObjectiveText();
            end
         end
         if(zdarzenie=="QUEST_DETAIL_LOG" or zdarzenie=="WORLDMAP_SELECTED_QUEST") then
            QTR_quest_EN.title=GetQuestLogTitle(GetQuestLogSelection()); 
            local questDescription, questObjectives = GetQuestLogQuestText();  
            QTR_quest_EN.details = questDescription;
            QTR_quest_EN.objectives = questObjectives;
            QTR_quest_EN.itemchoose = QTR_MessOrig.itemchoose1;
            QTR_quest_LG.itemchoose = QTR_Messages.itemchoose1;
            QTR_quest_EN.itemreceive = QTR_MessOrig.itemreceiv1;
            QTR_quest_LG.itemreceive = QTR_Messages.itemreceiv1; 

            if(QTR_quest_EN.details == nil or QTR_quest_EN.objectives == nil) then
               return; 
            end
            
            if (strlen(QTR_quest_EN.details)>0 and strlen(QTR_quest_LG.details)==0) then
               --QTR_MISSING[QTR_quest_EN.id.." DESCRIPTION"]=QTR_quest_EN.details;     -- save missing translation part
               if(QuestTradutor.target > 1 ) then
                  QTR_quest_LG.details = QTR_quest_EN.details .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing); 
               else
                  QTR_quest_LG.details = QTR_quest_EN.details .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing_v); 
               end
            end
            if (strlen(QTR_quest_EN.objectives)>0 and strlen(QTR_quest_LG.objectives)==0) then
              -- QTR_MISSING[QTR_quest_EN.id.." OBJECTIVE"]=QTR_quest_EN.objectives;    -- save missing translation part
               if(QuestTradutor.target > 1 ) then
                  QTR_quest_LG.objectives = QTR_quest_EN.objectives .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing); 
               else
                  QTR_quest_LG.objectives = QTR_quest_EN.objectives .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing_v); 
               end
            end
         end
         if (zdarzenie=="QUEST_PROGRESS") then
            QTR_quest_EN.progress = GetProgressText(); 
            if(QTR_PLAYERQUESTS[QTR_quest_EN.id]) then
               QTR_PLAYERQUESTS[QTR_quest_EN.id]["Progress"] = GetProgressText();
            end
            QTR_quest_LG.progress = QuestTradutor:ExpandUnitInfo(QuestTradutor:GetQuestData(str_ID, "Progress"));
            if (strlen(QTR_quest_EN.progress)>0 and strlen(QTR_quest_LG.progress)==0) then
               --QTR_MISSING[QTR_quest_EN.id.." PROGRESS"]=QTR_quest_EN.progress;     -- save missing translation part
               if(QuestTradutor.target > 1 ) then
                  QTR_quest_LG.progress = QTR_quest_EN.progress .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing); 
               else
                  QTR_quest_LG.progress = QTR_quest_EN.progress .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing_v); 
               end
            end
            if (strlen(QTR_quest_LG.progress)==0) then      -- treść jest pusta, a otworzono okienko Progress
               QTR_quest_LG.progress = QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.missingProgressText); 
            end
         end
         if (zdarzenie=="QUEST_COMPLETE") then
            QTR_quest_EN.completion = GetRewardText();  
            if(QTR_PLAYERQUESTS[QTR_quest_EN.id]) then  
               QTR_PLAYERQUESTS[QTR_quest_EN.id]["Completion"] = GetRewardText();
            end
            QTR_quest_LG.completion = QuestTradutor:ExpandUnitInfo(QuestTradutor:GetQuestData(str_ID, "Completion"));
            QTR_quest_EN.itemchoose = QTR_MessOrig.itemchoose2;
            QTR_quest_LG.itemchoose = QTR_Messages.itemchoose2;
            QTR_quest_EN.itemreceive = QTR_MessOrig.itemreceiv2;
            QTR_quest_LG.itemreceive = QTR_Messages.itemreceiv2;
            if (strlen(QTR_quest_EN.completion)>0 and strlen(QTR_quest_LG.completion)==0) then
               --QTR_MISSING[QTR_quest_EN.id.." COMPLETE"]=QTR_quest_EN.completion;     -- save missing translation part
               if(QuestTradutor.target > 1 ) then
                  QTR_quest_LG.completion = QTR_quest_EN.completion .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing); 
               else
                  QTR_quest_LG.completion = QTR_quest_EN.completion .. QuestTradutor:ExpandUnitInfo(QTR_ExtraTexts.translationmissing_v); 
               end
            end
         end         
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")"); 
         QTR_ToggleButtonWM:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");  
         if (QuestTradutor:isQuestGuru()) then
            QTR_ToggleButton3:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
            QTR_ToggleButton3:Enable();
         end
         if (QuestTradutor:isImmersion()) then
            QTR_ToggleButton4:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
            QTR_quest_EN.details = GetQuestText();
            QTR_quest_EN.progress = GetProgressText();
            QTR_quest_EN.completion = GetRewardText();
         end
         if (QuestTradutor:isStoryline() and Storyline_NPCFrame:IsVisible()) then
            QTR_ToggleButton5:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         end
         QuestTradutor:Translate_On(1); -- tds estao sendo chamados daq

      else	      -- nie ma przetłumaczonego takiego questu
         if (QTR_onDebug) then
            print('Nie znalazł tłumaczenia dla ID: '..str_ID);   
         end   
         QTR_ToggleButton0:Disable();
         QTR_ToggleButton1:Disable();
         QTR_ToggleButton2:Disable(); 
         QTR_ToggleButtonWM:Disable(); 
         if (QuestTradutor:isQuestGuru()) then
            QTR_ToggleButton3:Disable();
         end
         if (QuestTradutor:isImmersion()) then
            QTR_ToggleButton4:Disable();
         end
         if (QuestTradutor:isStoryline()) then
            QTR_ToggleButton5:Disable();
         end
         QTR_ToggleButton0:SetText("Quest ID="..str_ID);
         QTR_ToggleButton1:SetText("Quest ID="..str_ID);
         QTR_ToggleButton2:SetText("Quest ID="..str_ID);  
         QTR_ToggleButtonWM:SetText("Quest ID="..str_ID); 
         if (QuestTradutor:isQuestGuru()) then
            QTR_ToggleButton3:SetText("Quest ID="..str_ID);
         end
         if (QuestTradutor:isImmersion()) then
            if (q_ID==0) then
               if (ImmersionFrame.TitleButtons:IsVisible()) then
                  QTR_ToggleButton4:SetText("wybierz wpierw quest");
               end
            else
               QTR_ToggleButton4:SetText("Quest ID="..str_ID);
            end
         end
         if (QuestTradutor:isStoryline()) then
            QTR_ToggleButton5:SetText("Quest ID="..str_ID);
         end
         QuestTradutor:Translate_On(0); 
      end -- jest przetłumaczony quest w bazie
   else	-- tłumaczenia wyłączone
      QTR_ToggleButton0:Disable();
      QTR_ToggleButton1:Disable();
      QTR_ToggleButton2:Disable(); 
      QTR_ToggleButtonWM:Disable() 

      if ( QTR_QuestData[str_ID] ) then	-- ale jest tłumaczenie w bazie
         QTR_ToggleButton1:SetText("Quest ID="..str_ID.." (EN)");
         QTR_ToggleButton2:SetText("Quest ID="..str_ID.." (EN)"); 
         QTR_ToggleButtonWM:SetText("Quest ID="..str_ID.." (EN)");
         if (QuestTradutor:isQuestGuru()) then
            QTR_ToggleButton3:SetText("Quest ID="..str_ID.." (EN)");
         end
         if (QuestTradutor:isImmersion()) then
            QTR_ToggleButton4:SetText("Quest ID="..str_ID.." (EN)");
         end
         if (QuestTradutor:isStoryline()) then
            QTR_ToggleButton5:SetText("Quest ID="..str_ID.." (EN)");
         end 
      else
         QTR_ToggleButton1:SetText("Quest ID="..str_ID);
         QTR_ToggleButton2:SetText("Quest ID="..str_ID); 
         QTR_ToggleButtonWM:SetText("Quest ID="..str_ID);
         if (QuestTradutor:isQuestGuru()) then
            QTR_ToggleButton3:SetText("Quest ID="..str_ID);
         end
         if (QuestTradutor:isImmersion()) then
            QTR_ToggleButton4:SetText("Quest ID="..str_ID);
         end
         if (QuestTradutor:isStoryline()) then
            QTR_ToggleButton5:SetText("Quest ID="..str_ID);
         end  
      end
   end	-- tłumaczenia są włączone 
   
end 

local function QTR_WOTLK_Translate_On(typ) -- WOTLK
   if (QTR_onDebug) then
      print('traduzindo');   
   end   
   QuestInfoObjectivesHeader:SetFont(QTR_Font1, 18);
   QuestInfoObjectivesHeader:SetText(QTR_Messages.objectives); -- "Zadanie"

   QuestInfoRewardsHeader:SetFont(QTR_Font1, 18);
   QuestInfoRewardsHeader:SetText(QTR_Messages.rewards);      -- "Nagroda" 

   QuestInfoDescriptionHeader:SetFont(QTR_Font1, 18);
   QuestInfoDescriptionHeader:SetText(QTR_Messages.details);     -- "Szczegóły"
   
   QuestProgressRequiredItemsText:SetFont(QTR_Font1, 18);
   QuestProgressRequiredItemsText:SetText(QTR_Messages.reqitems);
   
--   QuestInfoSpellObjectiveLearnLabel:SetFont(QTR_Font2, 13);
--   QuestInfoSpellObjectiveLearnLabel:SetText(QTR_Messages.learnspell);
   QuestInfoXPFrameReceiveText:SetFont(QTR_Font2, 13);
   QuestInfoXPFrameReceiveText:SetText(QTR_Messages.experience);
--   MapQuestInfoRewardsFrame.ItemChooseText:SetFont(QTR_Font2, 11);
--   MapQuestInfoRewardsFrame.ItemReceiveText:SetFont(QTR_Font2, 11);
--   MapQuestInfoRewardsFrame.ItemChooseText:SetText(QTR_Messages.itemchoose1);
--   MapQuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_Messages.itemreceiv1);
   if (typ==1) then			-- pełne przełączenie (jest tłumaczenie)
      QuestInfoItemChooseText:SetFont(QTR_Font2, 13);
      QuestInfoItemChooseText:SetText(QTR_Messages.itemchoose1);
      QuestInfoItemReceiveText:SetFont(QTR_Font2, 13);
      QuestInfoItemReceiveText:SetText(QTR_Messages.itemreceiv1);
      numer_ID = QTR_quest_LG.id;
      str_ID = tostring(numer_ID);
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć przetłumaczoną wersję napisów
         if (QTR_onDebug) then
            print('tłum.ID='..str_ID);   
         end   
         if (QTR_PS["transtitle"]=="1") then    -- wyświetl przetłumaczony tytuł
          --  QuestLogQuestTitle:SetFont(QTR_Font1, 18);
          --  QuestLogQuestTitle:SetText(QTR_quest_LG.title);
            QuestInfoTitleHeader:SetFont(QTR_Font1, 18);
            QuestInfoTitleHeader:SetText(QTR_quest_LG.title);
           QuestProgressTitleText:SetFont(QTR_Font1, 18);
            QuestProgressTitleText:SetText(QTR_quest_LG.title);
         end
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")"); 
         QTR_ToggleButtonWM:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")"); 
         
         if (QuestTradutor:isQuestGuru()) then
            QTR_ToggleButton3:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         end
         if (QuestTradutor:isImmersion()) then
            QTR_ToggleButton4:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
            if (not QuestTradutor:wait(0.2, QuestTradutor.Immersion)) then    -- wywołaj podmienianie danych po 0.2 sek
               -- opóźnienie 0.2 sek
            end
         end
         if (QuestTradutor:isStoryline() and Storyline_NPCFrame:IsVisible()) then
            QTR_ToggleButton5:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
            QuestTradutor:Storyline(1);
         end
         QuestInfoDescriptionText:SetFont(QTR_Font2, 13);
         QuestInfoDescriptionText:SetText(QTR_quest_LG.details);
         QuestInfoDescriptionText:SetFont(QTR_Font2, 13);
         QuestInfoDescriptionText:SetText(QTR_quest_LG.details);
         QuestInfoObjectivesText:SetFont(QTR_Font2, 13);
         QuestInfoObjectivesText:SetText(QTR_quest_LG.objectives);
         QuestProgressText:SetFont(QTR_Font2, 13);
         QuestProgressText:SetText(QTR_quest_LG.progress);
         
         
        -- QuestLogObjectivesText:SetFont(QTR_Font2, 13);
        -- QuestLogObjectivesText:SetText(QTR_quest_LG.objectives);
         
         QuestProgressText:SetFont(QTR_Font2, 13);
         QuestProgressText:SetText(QTR_quest_LG.progress);
         QuestInfoRewardText:SetFont(QTR_Font2, 13);
         QuestInfoRewardText:SetText(QTR_quest_LG.completion);
         
    --     QuestInfoRewardsFrame.ItemChooseText:SetFont(QTR_Font2, 13);
      --   QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_quest_LG.itemchoose);
        -- QuestInfoRewardsFrame.ItemReceiveText:SetFont(QTR_Font2, 13);
        -- QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_quest_LG.itemreceive);
      end
   else
      if (curr_trans == "1") then
       --  QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_Messages.itemchoose1);
        -- QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_Messages.itemreceiv1);
         if ((ImmersionFrame ~= nil ) and (ImmersionFrame.TalkBox:IsVisible() )) then
            if (not QuestTradutor:wait(0.2,QuestTradutor.Immersion_Static)) then
               -- podmiana tekstu z opóźnieniem 0.2 sek
            end
         end
      end
   end
end

-- wyświetla tłumaczenie
function QuestTradutor:Translate_On(typ)
   
   if(QuestTradutor.target > 2) then QTR_WOTLK_Translate_On(typ) return end

   if (QTR_onDebug) then
      print('traduzindo');   
   end 
   if(QuestDetailObjectiveTitleText)  then
      QuestDetailObjectiveTitleText:SetFont(QTR_Font1, 18);
      QuestDetailObjectiveTitleText:SetText(QTR_Messages.objectives); -- "Zadanie" 
   end
   if(QuestLogObjectiveTitleText) then
      QuestLogObjectiveTitleText:SetFont(QTR_Font1, 18);
      QuestLogObjectiveTitleText:SetText(QTR_Messages.objectives); -- "Zadanie" 
   end

   if(QuestLogDescriptionTitle) then 
      QuestLogDescriptionTitle:SetFont(QTR_Font1, 18);       -- Description
      QuestLogDescriptionTitle:SetText(QTR_Messages.details);
   end
   
   if(QuestLogRewardTitleText) then
      QuestLogRewardTitleText:SetFont(QTR_Font1, 18);
      QuestLogRewardTitleText:SetText(QTR_Messages.rewards);
   end

   if(QuestDetailRewardTitleText) then
      QuestDetailRewardTitleText:SetFont(QTR_Font1, 18);
      QuestDetailRewardTitleText:SetText(QTR_Messages.rewards);
   end 
   

   if(QuestRewardRewardTitleText) then
      QuestRewardRewardTitleText:SetFont(QTR_Font1, 18);
      QuestRewardRewardTitleText:SetText(QTR_Messages.rewards);
   end 

   if (typ==1) then			-- pełne przełączenie (jest tłumaczenie)
      if(QuestLogItemChooseText) then
         QuestLogItemChooseText:SetFont(QTR_Font2, 13);
         QuestLogItemChooseText:SetText(QTR_Messages.itemchoose1);
      end
      
      if(QuestRewardItemChooseText) then
         QuestRewardItemChooseText:SetFont(QTR_Font2, 13);
         QuestRewardItemChooseText:SetText(QTR_Messages.itemchoose1);
      end
      
      if(QuestDetailItemChooseText) then
         QuestDetailItemChooseText:SetFont(QTR_Font2, 13);
         QuestDetailItemChooseText:SetText(QTR_Messages.itemchoose1);
      end

      if(QuestLogItemReceiveText) then 
         QuestLogItemReceiveText:SetFont(QTR_Font2, 13);
         QuestLogItemReceiveText:SetText(QTR_Messages.itemreceiv1);
      end
      
      if(QuestRewardItemReceiveText) then
         QuestRewardItemReceiveText:SetFont(QTR_Font2, 13);
         QuestRewardItemReceiveText:SetText(QTR_Messages.itemreceiv1);
      end
      
      if(QuestDetailItemReceiveText) then
         QuestDetailItemReceiveText:SetFont(QTR_Font2, 13);
         QuestDetailItemReceiveText:SetText(QTR_Messages.itemreceiv1);
      end

      numer_ID = QTR_quest_LG.id;
      str_ID = tostring(numer_ID);
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć przetłumaczoną wersję napisów
         if (QTR_onDebug) then
            print('tłum.ID='..str_ID);   
         end   
         if (QTR_PS["transtitle"]=="1") then    -- wyświetl przetłumaczony tytuł
            QuestTitleText:SetFont(QTR_Font1, 18);
            QuestTitleText:SetText(QTR_quest_LG.title);
            if(QuestProgressTitleText) then
               QuestProgressTitleText:SetFont(QTR_Font1, 18);
               QuestProgressTitleText:SetText(QTR_quest_LG.title);
            end
            if(QuestRewardTitleText) then
               QuestRewardTitleText:SetFont(QTR_Font1, 18);
               QuestRewardTitleText:SetText(QTR_quest_LG.title);
            end 
            if(QuestLogTitleText) then
               QuestLogQuestTitle:SetFont(QTR_Font1, 18);
               QuestLogQuestTitle:SetText(QTR_quest_LG.title);
            end
         end
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")"); 
         QTR_ToggleButtonWM:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")"); 
         
         if (QuestTradutor:isQuestGuru()) then
            QTR_ToggleButton3:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         end
         if (QuestTradutor:isImmersion()) then
            QTR_ToggleButton4:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
            if (not QuestTradutor:wait(0.2, QuestTradutor.Immersion)) then    -- wywołaj podmienianie danych po 0.2 sek
               -- opóźnienie 0.2 sek
            end
         end
         if (QuestTradutor:isStoryline() and Storyline_NPCFrame:IsVisible()) then
            QTR_ToggleButton5:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
            QuestTradutor:Storyline(1);
         end

         if(QuestDescription) then
            QuestDescription:SetFont(QTR_Font2, 13);
            QuestDescription:SetText(QTR_quest_LG.details);
         end
         if(QuestLogQuestDescription) then
            QuestLogQuestDescription:SetFont(QTR_Font2, 13);
            QuestLogQuestDescription:SetText(QTR_quest_LG.details);
         end

         if(QuestObjectiveText) then
            QuestObjectiveText:SetFont(QTR_Font2, 13);
            QuestObjectiveText:SetText(QTR_quest_LG.objectives);
         end
         if(QuestLogObjectivesText) then 
            QuestLogObjectivesText:SetFont(QTR_Font2, 13);
            QuestLogObjectivesText:SetText(QTR_quest_LG.objectives);
         end
         if(QuestProgressText) then
            QuestProgressText:SetFont(QTR_Font2, 13);
            QuestProgressText:SetText(QTR_quest_LG.progress);
         end
         
        if(QuestRewardText) then
         QuestRewardText:SetFont(QTR_Font2, 13);
         QuestRewardText:SetText(QTR_quest_LG.completion);
        end
         
      end
   else
      if (curr_trans == "1") then
         if ((ImmersionFrame ~= nil ) and (ImmersionFrame.TalkBox:IsVisible() )) then
            if (not QuestTradutor:wait(0.2, QuestTradutor.Immersion_Static)) then
               -- podmiana tekstu z opóźnieniem 0.2 sek
            end
         end
      end
   end
end


local function QTR_WOTLK_Translate_Off(typ) -- WOTLK
   QuestInfoTitleHeader:SetFont(Original_Font1, 18);
   QuestInfoTitleHeader:SetText(QTR_quest_EN.title);
   QuestProgressTitleText:SetText(QTR_quest_EN.title);        
   QuestProgressTitleText:SetFont(Original_Font1, 18);
   
--   QuestLogQuestTitle:SetFont(Original_Font1, 18);
--   QuestLogQuestTitle:SetText(QTR_quest_EN.title);
   
   QuestInfoObjectivesHeader:SetFont(Original_Font1, 18);      -- Quest Objectives
   QuestInfoObjectivesHeader:SetText(QTR_MessOrig.objectives);

   QuestInfoRewardsHeader:SetFont(Original_Font1, 18);        -- Reward
   QuestInfoRewardsHeader:SetText(QTR_MessOrig.rewards); 
   
   QuestInfoDescriptionHeader:SetFont(Original_Font1, 18);       -- Description
   QuestInfoDescriptionHeader:SetText(QTR_MessOrig.details);
   
   QuestProgressRequiredItemsText:SetFont(Original_Font1, 18);
   QuestProgressRequiredItemsText:SetText(QTR_MessOrig.reqitems);
   
--   MapQuestInfoRewardsFrame.ItemReceiveText:SetFont(Original_Font2, 11);
--   MapQuestInfoRewardsFrame.ItemChooseText:SetFont(Original_Font2, 11);
   QuestInfoSpellLearnText:SetFont(Original_Font2, 13);
   QuestInfoSpellLearnText:SetText(QTR_MessOrig.learnspell);
   QuestInfoXPFrameReceiveText:SetFont(Original_Font2, 13);
   QuestInfoXPFrameReceiveText:SetText(QTR_MessOrig.experience);
   if (typ==1) then			-- pełne przełączenie (jest tłumaczenie)
      QuestInfoItemChooseText:SetFont(Original_Font2, 13);
      QuestInfoItemChooseText:SetText(QTR_MessOrig.itemchoose1);
      QuestInfoItemReceiveText:SetFont(Original_Font2, 13);
      QuestInfoItemReceiveText:SetText(QTR_MessOrig.itemreceiv1);
--      MapQuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_MessOrig.itemreceiv1);
--      MapQuestInfoRewardsFrame.ItemChooseText:SetText(QTR_MessOrig.itemreceiv1);
      numer_ID = QTR_quest_EN.id;
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć oryginalną wersję napisów
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_EN.id.." (EN)"); 
         QTR_ToggleButtonWM:SetText("Quest ID="..QTR_quest_EN.id.." (EN)"); 
         if (QuestGuru ~= nil ) then
            QTR_ToggleButton3:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
         end 

         if (ImmersionFrame ~= nil ) then
            QTR_ToggleButton4:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
            QuestTradutor:Immersion_OFF();
            ImmersionFrame.TalkBox.TextFrame.Text:RepeatTexts();   --reload text
         end
         if (QuestTradutor:isStoryline()) then
            QTR_ToggleButton5:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
            QuestTradutor:Storyline_OFF(1);
         end

  --       QuestLogQuestDescription:SetFont(Original_Font2, 13);
  --       QuestLogQuestDescription:SetText(QTR_quest_EN.details);
         QuestInfoDescriptionText:SetFont(Original_Font2, 13);
         QuestInfoDescriptionText:SetText(QTR_quest_EN.details);
         QuestInfoObjectivesText:SetFont(Original_Font2, 13);
         QuestInfoObjectivesText:SetText(QTR_quest_EN.objectives);
         
 --        QuestLogObjectivesText:SetFont(Original_Font2, 13);
  --       QuestLogObjectivesText:SetText(QTR_quest_EN.objectives);
         
         QuestProgressText:SetFont(Original_Font2, 13);
         QuestProgressText:SetText(QTR_quest_EN.progress);
         QuestInfoRewardText:SetFont(Original_Font2, 13);
         QuestInfoRewardText:SetText(QTR_quest_EN.completion);
         
 --        QuestInfoRewardsFrame.ItemChooseText:SetFont(Original_Font2, 13);
  --       QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_quest_EN.itemchoose);
 --        QuestInfoRewardsFrame.ItemReceiveText:SetFont(Original_Font2, 13);
  --       QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_quest_EN.itemreceive);
      end
   else   
      if (curr_trans == "0") then
         if ((ImmersionFrame ~= nil ) and (ImmersionFrame.TalkBox:IsVisible() )) then
            if (not QuestTradutor:wait(0.2, QuestTradutor.Immersion_OFF_Static)) then
               -- podmiana tekstu z opóźnieniem 0.2 sek
            end
         end
      end
   end
end


function QuestTradutor:Translate_Off(typ)

   if(QuestTradutor.target > 2) then QTR_WOTLK_Translate_Off(typ) return end

   if(QuestDetailObjectiveTitleText)  then
      QuestDetailObjectiveTitleText:SetFont(Original_Font1, 18);
      QuestDetailObjectiveTitleText:SetText(QTR_MessOrig.objectives); -- "Zadanie" 
   end
   if(QuestLogObjectiveTitleText) then
      QuestLogObjectiveTitleText:SetFont(Original_Font1, 18);
      QuestLogObjectiveTitleText:SetText(QTR_MessOrig.objectives); -- "Zadanie" 
   end

   if(QuestLogDescriptionTitle) then 
      QuestLogDescriptionTitle:SetFont(Original_Font1, 18);       -- Description
      QuestLogDescriptionTitle:SetText(QTR_MessOrig.details);
   end
   
   if(QuestLogRewardTitleText) then
      QuestLogRewardTitleText:SetFont(Original_Font1, 18);
      QuestLogRewardTitleText:SetText(QTR_MessOrig.rewards);
   end

   if(QuestRewardRewardTitleText) then
      QuestRewardRewardTitleText:SetFont(Original_Font1, 18);
      QuestRewardRewardTitleText:SetText(QTR_MessOrig.rewards);
   end
   if(QuestDetailRewardTitleText) then
      QuestDetailRewardTitleText:SetFont(Original_Font1, 18);
      QuestDetailRewardTitleText:SetText(QTR_MessOrig.rewards);
   end

   if(QuestProgressTitleText) then
      QuestProgressTitleText:SetFont(Original_Font1, 18);
      QuestProgressTitleText:SetText(QTR_quest_EN.title);
   end
   if(QuestTitleText) then
      QuestTitleText:SetFont(Original_Font1, 18);
      QuestTitleText:SetText(QTR_quest_EN.title);
   end

   if(QuestLogTitleText) then
      QuestLogQuestTitle:SetFont(Original_Font1, 18);
      QuestLogQuestTitle:SetText(QTR_quest_EN.title);
   end
   
   if(QuestRewardTitleText) then
      QuestRewardTitleText:SetFont(Original_Font1, 18);
      QuestRewardTitleText:SetText(QTR_quest_EN.title);
   end





   if (typ==1) then
      if(QuestLogItemChooseText) then
         QuestLogItemChooseText:SetFont(Original_Font2, 13);
         QuestLogItemChooseText:SetText(QTR_MessOrig.itemchoose1);
      end

      if(QuestRewardItemChooseText) then
         QuestRewardItemChooseText:SetFont(Original_Font2, 13);
         QuestRewardItemChooseText:SetText(QTR_MessOrig.itemchoose1);
      end

      if(QuestDetailItemChooseText) then
         QuestDetailItemChooseText:SetFont(Original_Font2, 13);
         QuestDetailItemChooseText:SetText(QTR_MessOrig.itemchoose1);
      end

      if(QuestLogItemReceiveText) then 
         QuestLogItemReceiveText:SetFont(Original_Font2, 13);
         QuestLogItemReceiveText:SetText(QTR_MessOrig.itemreceiv1);
      end

      if(QuestRewardItemReceiveText) then
         QuestRewardItemReceiveText:SetFont(Original_Font2, 13);
         QuestRewardItemReceiveText:SetText(QTR_MessOrig.itemreceiv1);
      end

      if(QuestDetailItemReceiveText) then
         QuestDetailItemReceiveText:SetFont(Original_Font2, 13);
         QuestDetailItemReceiveText:SetText(QTR_MessOrig.itemreceiv1);
      end


      numer_ID = QTR_quest_EN.id;
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć oryginalną wersję napisów
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_EN.id.." (EN)"); 
         QTR_ToggleButtonWM:SetText("Quest ID="..QTR_quest_EN.id.." (EN)"); 
         if (QuestGuru ~= nil ) then
            QTR_ToggleButton3:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
         end 

         if (ImmersionFrame ~= nil ) then
            QTR_ToggleButton4:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
            QuestTradutor:Immersion_OFF();
            ImmersionFrame.TalkBox.TextFrame.Text:RepeatTexts();   --reload text
         end
         if (QuestTradutor:isStoryline()) then
            QTR_ToggleButton5:SetText("Quest ID="..QTR_quest_EN.id.." (EN)");
            QuestTradutor:Storyline_OFF(1);
         end

         if(QuestDescription) then
            QuestDescription:SetFont(Original_Font2, 13);
            QuestDescription:SetText(QTR_quest_EN.details);
         end
         if(QuestLogQuestDescription) then
            QuestLogQuestDescription:SetFont(Original_Font2, 13);
            QuestLogQuestDescription:SetText(QTR_quest_EN.details);
         end

         if(QuestObjectiveText) then
            QuestObjectiveText:SetFont(Original_Font2, 13);
            QuestObjectiveText:SetText(QTR_quest_EN.objectives);
         end
         if(QuestLogObjectivesText) then 
            QuestLogObjectivesText:SetFont(Original_Font2, 13);
            QuestLogObjectivesText:SetText(QTR_quest_EN.objectives);
         end
         if(QuestProgressText) then
            QuestProgressText:SetFont(Original_Font2, 13);
            QuestProgressText:SetText(QTR_quest_EN.progress);
         end
         
        if(QuestRewardText) then
         QuestRewardText:SetFont(Original_Font2, 13);
         QuestRewardText:SetText(QTR_quest_EN.completion);
        end
      end
   else   
      if (curr_trans == "0") then
         if ((ImmersionFrame ~= nil ) and (ImmersionFrame.TalkBox:IsVisible() )) then
            if (not QuestTradutor:wait(0.2,QuestTradutor.Immersion_OFF_Static)) then
               -- 
            end
         end
      end
   end
end


function QuestTradutor:delayed3()
   QTR_ToggleButton4:SetText("wybierz wpierw quest");
   QTR_ToggleButton4:Hide();
   if (not QuestTradutor:wait(1,QuestTradutor.delayed4)) then
   ---
   end
end


function QuestTradutor:delayed4()
   if (ImmersionFrame.TitleButtons:IsVisible()) then
      if (ImmersionFrame.TitleButtons.Buttons[1] ~= nil ) then
         if(QuestTradutor.target > 1) then
            ImmersionFrame.TitleButtons.Buttons[1]:HookScript("OnClick", function() QTR_PrepareDelay(1) end);
         else
            HookScript(ImmersionFrame.TitleButtons.Buttons[1], "OnClick", function() QTR_PrepareDelay(1) end);
         end
      end
      if (ImmersionFrame.TitleButtons.Buttons[2] ~= nil ) then
         if(QuestTradutor.target > 1) then
            ImmersionFrame.TitleButtons.Buttons[2]:HookScript("OnClick", function() QTR_PrepareDelay(1) end);
         else
            HookScript(ImmersionFrame.TitleButtons.Buttons[2], "OnClick", function() QTR_PrepareDelay(1) end);
         end 
      end
      if (ImmersionFrame.TitleButtons.Buttons[3] ~= nil ) then
         if(QuestTradutor.target > 1) then
            ImmersionFrame.TitleButtons.Buttons[3]:HookScript("OnClick", function() QTR_PrepareDelay(1) end);
         else
            HookScript(ImmersionFrame.TitleButtons.Buttons[3], "OnClick", function() QTR_PrepareDelay(1) end);
         end  
      end   
      if (ImmersionFrame.TitleButtons.Buttons[4] ~= nil ) then
         if(QuestTradutor.target > 1) then
            ImmersionFrame.TitleButtons.Buttons[4]:HookScript("OnClick", function() QTR_PrepareDelay(1) end);
         else
            HookScript(ImmersionFrame.TitleButtons.Buttons[4], "OnClick", function() QTR_PrepareDelay(1) end);
         end  
      end
      if (ImmersionFrame.TitleButtons.Buttons[5] ~= nil ) then
         if(QuestTradutor.target > 1) then
            ImmersionFrame.TitleButtons.Buttons[5]:HookScript("OnClick", function() QTR_PrepareDelay(1) end);
         else
            HookScript(ImmersionFrame.TitleButtons.Buttons[5], "OnClick", function() QTR_PrepareDelay(1) end);
         end  
      end
   end

   QuestTradutor:QuestPrepare('');
end;      


function QuestTradutor:PrepareDelay(czas)     -- wywoływane po kliknięciu na nazwę questu z listy NPC
   if (czas==1) then
      if (not QuestTradutor:wait(1,QuestTradutor.PrepareReload)) then
      ---
      end
   end
   if (czas==3) then
      if (not QuestTradutor:wait(3,QuestTradutor.PrepareReload)) then
      ---
      end
   end
end;      


function QuestTradutor:PrepareReload()
   QuestTradutor:QuestPrepare('');
end;      


function QuestTradutor:Prepare1sek()   
   if (not QuestTradutor:wait(0.1,QuestTradutor.PrepareReload)) then
   ---
   end
end;       


function QuestTradutor:Immersion()   -- wywoływanie tłumaczenia z opóźnieniem 0.2 sek 
  ImmersionContentFrame.ObjectivesText:SetText(QTR_quest_LG.objectives); 
  ImmersionFrame.TalkBox.NameFrame.Name:SetText(QTR_quest_LG.title); 
  if (strlen(QTR_quest_EN.details)>0) then                                    -- mamy zdarzenie DETAILS
     ImmersionFrame.TalkBox.TextFrame.Text:SetText(QTR_quest_LG.details);
  elseif (strlen(QTR_quest_EN.completion)>0) then
     ImmersionFrame.TalkBox.TextFrame.Text:SetText(QTR_quest_LG.completion);
  else
     ImmersionFrame.TalkBox.TextFrame.Text:SetText(QTR_quest_LG.progress);
  end
  QuestTradutor:Immersion_Static();        -- inne statyczne dane
end


function QuestTradutor:Immersion_Static()  
  ImmersionContentFrame.ObjectivesHeader:SetText(QTR_Messages.objectives);  -- "Zadanie" 
  ImmersionContentFrame.RewardsFrame.Header:SetText(QTR_Messages.rewards);  -- "Nagroda" 
  ImmersionContentFrame.RewardsFrame.ItemChooseText:SetText(QTR_Messages.itemchoose1); -- "Możesz wybrać nagrodę:" 
  ImmersionContentFrame.RewardsFrame.ItemReceiveText:SetText(QTR_Messages.itemreceiv1); -- "Otrzymasz w nagrodę:" 
  ImmersionContentFrame.RewardsFrame.XPFrame.ReceiveText:SetText(QTR_Messages.experience);  -- "Doświadczenie" 
  ImmersionFrame.TalkBox.Elements.Progress.ReqText:SetText(QTR_Messages.reqitems);  -- "Wymagane itemy:"
end


function QuestTradutor:Immersion_OFF()   -- wywoływanie oryginału ;
  ImmersionContentFrame.ObjectivesText:SetText(QTR_quest_EN.objectives); 
  ImmersionFrame.TalkBox.NameFrame.Name:SetText(QTR_quest_EN.title); 
  if (strlen(QTR_quest_EN.details)>0) then                                    -- przywróć oryginalny tekst
     ImmersionFrame.TalkBox.TextFrame.Text:SetText(QTR_quest_EN.details);
  elseif (strlen(QTR_quest_EN.progress)>0) then
     ImmersionFrame.TalkBox.TextFrame.Text:SetText(QTR_quest_EN.progress);
  else
     ImmersionFrame.TalkBox.TextFrame.Text:SetText(QTR_quest_EN.completion);
  end
  QuestTradutor:Immersion_OFF_Static();       -- inne statyczne dane
end


function QuestTradutor:Immersion_OFF_Static() 
  ImmersionContentFrame.ObjectivesHeader:SetText(QTR_MessOrig.objectives);  -- "Zadanie" 
  ImmersionContentFrame.RewardsFrame.Header:SetText(QTR_MessOrig.rewards);  -- "Nagroda" 
  ImmersionContentFrame.RewardsFrame.ItemChooseText:SetText(QTR_MessOrig.itemchoose1); -- "Możesz wybrać nagrodę:" 
  ImmersionContentFrame.RewardsFrame.ItemReceiveText:SetText(QTR_MessOrig.itemreceiv1); -- "Otrzymasz w nagrodę:" 
  ImmersionContentFrame.RewardsFrame.XPFrame.ReceiveText:SetText(QTR_MessOrig.experience);  -- "Doświadczenie" 
  ImmersionFrame.TalkBox.Elements.Progress.ReqText:SetText(QTR_MessOrig.reqitems);  -- "Wymagane itemy:"
end


function QuestTradutor:Storyline_Delay()
   QuestTradutor:Storyline(1);
end


function QuestTradutor:Storyline_Quest()
   if (QTR_PS["active"]=="1" and QTR_PS["other3"]=="1" and Storyline_NPCFrameTitle:IsVisible()) then
      QuestTradutor:QuestPrepare('');
   end
end


function QuestTradutor:Storyline_Hide()
   if (QTR_PS["active"]=="1" and QTR_PS["other3"]=="1") then
      QTR_ToggleButton5:Hide();
   end
end


function QuestTradutor:Storyline_Objectives()
   if (QTR_onDebug) then
      print("QTR_ST: objectives");
   end
   if (QTR_PS["active"]=="1" and QTR_PS["other3"]=="1" and QTR_quest_LG.id>0) then
      local string_ID= tostring(QTR_quest_LG.id);
      Storyline_NPCFrameObjectivesContent.Title:SetText('Zadanie');
      if (QTR_QuestData[string_ID] ) then
         Storyline_NPCFrameObjectivesContent.Objectives:SetText(QuestTradutor:ExpandUnitInfo(QTR_QuestData[string_ID]["Objectives"])); 
      end   
   end
end


function QuestTradutor:Storyline_Rewards()
   if (QTR_onDebug) then
      print("QTR_ST: rewards");
   end
   if (QTR_PS["active"]=="1" and QTR_PS["other3"]=="1") then
      Storyline_NPCFrameRewards.Content.Title:SetText('Recompensa');
   end
end


function QuestTradutor:Storyline(nr)
   if (QTR_onDebug) then
      print('QTR_ST: Podmieniam quest '..QTR_quest_LG.id);
   end
   if (QTR_PS["transtitle"]=="1") then
      Storyline_NPCFrameTitle:SetText(QTR_quest_LG.title);
      Storyline_NPCFrameTitle:SetFont(QTR_Font2, 18);
   end
   local string_ID= tostring(QTR_quest_LG.id);
   local texts = { "" };
   if ((Storyline_NPCFrameChat.event ~= nil) and (QTR_QuestData[string_ID] ~= nil))then
      local event = Storyline_NPCFrameChat.event;
      if (event=="QUEST_DETAIL") then
     	   texts = { strsplit("\n", QuestTradutor:ExpandUnitInfo(QTR_QuestData[string_ID]["Description"])) };
      end   
      if (event=="QUEST_PROGRESS") then
     	   texts = { strsplit("\n", QuestTradutor:ExpandUnitInfo(QTR_QuestData[string_ID]["Progress"])) };
      end   
      if (event=="QUEST_COMPLETE") then
     	   texts = { strsplit("\n", QuestTradutor:ExpandUnitInfo(QTR_QuestData[string_ID]["Completion"])) };
      end   
   end
   local ileOry = table.getn(Storyline_NPCFrameChat.texts);
   local indeks = 0;
   for i=1, table.getn(texts) do
      if texts[i]:len() > 0 then
         if (indeks<ileOry) then
            indeks=indeks+1;
            Storyline_NPCFrameChat.texts[indeks]=texts[i];
         end
      end
   end
   Storyline_NPCFrameChatText:SetFont(QTR_Font2, 16);
   if (nr==1) then      -- Reload text
      Storyline_NPCFrameObjectivesContent:Hide();
      Storyline_NPCFrame.chat.currentIndex = 0;
      Storyline_API.playNext(Storyline_NPCFrameModelsYou);  -- reload
   end
end


function QuestTradutor:Storyline_OFF(nr)
   if (QTR_onDebug) then
      print('QTR_SToff: Przywracam quest '..QTR_quest_EN.id);
   end
   if (QTR_PS["transtitle"]=="1") then
      Storyline_NPCFrameTitle:SetText(QTR_quest_EN.title);
      Storyline_NPCFrameTitle:SetFont(Original_Font2, 18);
   end
   local string_ID= tostring(QTR_quest_EN.id);
   local texts = { "" };
   if ((Storyline_NPCFrameChat.event ~= nil) and (QTR_QuestData[string_ID] ~= nil))then
      local event = Storyline_NPCFrameChat.event;
      if (event=="QUEST_DETAIL") then
     	   texts = { strsplit("\n", GetQuestText()) };
      end   
      if (event=="QUEST_PROGRESS") then
     	   texts = { strsplit("\n", GetProgressText()) };
      end   
      if (event=="QUEST_COMPLETE") then
     	   texts = { strsplit("\n", GetRewardText()) };
      end   
   end
   local ileOry = table.getn(Storyline_NPCFrameChat.texts);
   local indeks = 0;
   for i=1, table.getn(texts) do
      if texts[i]:len() > 0 then
         if (indeks<ileOry) then
            indeks=indeks+1;
            Storyline_NPCFrameChat.texts[indeks]=texts[i];
         end
      end
   end
   Storyline_NPCFrameChatText:SetFont(Original_Font2, 16);
   if (nr==1) then      -- Reload text
      Storyline_NPCFrameObjectivesContent:Hide();
      Storyline_NPCFrame.chat.currentIndex = 0;
      Storyline_API.playNext(Storyline_NPCFrameModelsYou);  -- reload
   end
end


-- podmieniaj specjane znaki w tekście
function QuestTradutor:ExpandUnitInfo(msg)
   msg = string.gsub(msg, "NEW_LINE", "\n");
   msg = string.gsub(msg, "YOUR_NAME", QTR_name);
   
-- jeszcze obsłużyć YOUR_GENDER(x;y)
   local nr_1, nr_2, nr_3 = 0;
   local QTR_forma = "";
   local nr_poz = string.find(msg, "YOUR_GENDER");    -- gdy nie znalazł, jest: nil
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      while (string.sub(msg, nr_1, nr_1) ~= "(") do
         nr_1 = nr_1 + 1;
      end
      if (string.sub(msg, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         while (string.sub(msg, nr_2, nr_2) ~= ";") do
            nr_2 = nr_2 + 1;
         end
         if (string.sub(msg, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            while (string.sub(msg, nr_3, nr_3) ~= ")") do
               nr_3 = nr_3 + 1;
            end
            if (string.sub(msg, nr_3, nr_3) == ")") then
               if (QTR_sex==3) then        -- forma żeńska
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               else                        -- forma męska
                  QTR_forma = string.sub(msg,nr_1+1,nr_2-1);
               end
               msg = string.sub(msg,1,nr_poz-1) .. QTR_forma .. string.sub(msg,nr_3+1);
            end   
         end
      end
      nr_poz = string.find(msg, "YOUR_GENDER");
   end

-- jeszcze obsłużyć NPC_GENDER(x;y)
   local nr_1, nr_2, nr_3 = 0;
   local QTR_forma = "";
   local nr_poz = string.find(msg, "NPC_GENDER");    -- gdy nie znalazł, jest: nil
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      while (string.sub(msg, nr_1, nr_1) ~= "(") do
         nr_1 = nr_1 + 1;
      end
      if (string.sub(msg, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         while (string.sub(msg, nr_2, nr_2) ~= ";") do
            nr_2 = nr_2 + 1;
         end
         if (string.sub(msg, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            while (string.sub(msg, nr_3, nr_3) ~= ")") do
               nr_3 = nr_3 + 1;
            end
            if (string.sub(msg, nr_3, nr_3) == ")") then
               if (QTR_sex==3) then        -- forma żeńska
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               else                        -- forma męska
                  QTR_forma = string.sub(msg,nr_1+1,nr_2-1);
               end
               msg = string.sub(msg,1,nr_poz-1) .. QTR_forma .. string.sub(msg,nr_3+1);
            end   
         end
      end
      nr_poz = string.find(msg, "NPC_GENDER");
   end

   if (QTR_sex==3) then        -- płeć żeńska
      msg = string.gsub(msg, "YOUR_CLASS1", player_class.M2);          -- Mianownik (kto, co?)
      msg = string.gsub(msg, "YOUR_CLASS2", player_class.D2);          -- Dopełniacz (kogo, czego?)
      msg = string.gsub(msg, "YOUR_CLASS3", player_class.C2);          -- Celownik (komu, czemu?)
      msg = string.gsub(msg, "YOUR_CLASS4", player_class.B2);          -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_CLASS5", player_class.N2);          -- Narzędnik (z kim, z czym?)
      msg = string.gsub(msg, "YOUR_CLASS6", player_class.K2);          -- Miejscownik (o kim, o czym?)
      msg = string.gsub(msg, "YOUR_CLASS7", player_class.W2);          -- Wołacz (o!)
      msg = string.gsub(msg, "YOUR_RACE1", player_race.M2);            -- Mianownik (kto, co?)
      msg = string.gsub(msg, "YOUR_RACE2", player_race.D2);            -- Dopełniacz (kogo, czego?)
      msg = string.gsub(msg, "YOUR_RACE3", player_race.C2);            -- Celownik (komu, czemu?)
      msg = string.gsub(msg, "YOUR_RACE4", player_race.B2);            -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_RACE5", player_race.N2);            -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, "YOUR_RACE6", player_race.K2);            -- Miejscownik (o kim, o czym?)
      msg = string.gsub(msg, "YOUR_RACE7", player_race.W2);            -- Wołacz (o!)
      msg = string.gsub(msg, "YOUR_RACE YOUR_CLASS", "YOUR_RACE "..player_class.M2);     -- Mianownik (kto, co?)
      msg = string.gsub(msg, "ą YOUR_RACE", "ą "..player_race.N2);              -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, " jesteś YOUR_RACE", " jesteś "..player_race.N2);    -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, "YOUR_RACE", player_race.W2);                        -- Wołacz - pozostałe wystąpienia
      msg = string.gsub(msg, "ą YOUR_CLASS", "ą "..player_class.N2);            -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, "esteś YOUR_CLASS", "esteś "..player_class.N2);      -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, " z Ciebie YOUR_CLASS", " z Ciebie "..player_class.M2);    -- Mianownik (kto, co?)
      msg = string.gsub(msg, " kolejny YOUR_CLASS do ", " kolejny "..player_class.M2.." do ");   -- Mianownik (kto, co?)
      msg = string.gsub(msg, " taki YOUR_CLASS", " taki "..player_class.M2);      -- Mianownik (kto, co?)
      msg = string.gsub(msg, "ako YOUR_CLASS", "ako "..player_class.M2);          -- Mianownik (kto, co?)
      msg = string.gsub(msg, " co sprowadza YOUR_CLASS", " co sprowadza "..player_class.B2);     -- Biernik (kogo, co?)
      msg = string.gsub(msg, " będę miał YOUR_CLASS", " będę miał "..player_class.B2);  -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_CLASS taki jak ", player_class.B2.." taki jak ");    -- Biernik (kogo, co?)
      msg = string.gsub(msg, " jak na YOUR_CLASS", " jak na "..player_class.B2);        -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_CLASS", player_class.W2);                      -- Wołacz - pozostałe wystąpienia
   else                    -- płeć męska
      msg = string.gsub(msg, "YOUR_CLASS1", player_class.M1);          -- Mianownik (kto, co?)
      msg = string.gsub(msg, "YOUR_CLASS2", player_class.D1);          -- Dopełniacz (kogo, czego?)
      msg = string.gsub(msg, "YOUR_CLASS3", player_class.C1);          -- Celownik (komu, czemu?)
      msg = string.gsub(msg, "YOUR_CLASS4", player_class.B1);          -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_CLASS5", player_class.N1);          -- Narzędnik (z kim, z czym?)
      msg = string.gsub(msg, "YOUR_CLASS6", player_class.K1);          -- Miejscownik (o kim, o czym?)
      msg = string.gsub(msg, "YOUR_CLASS7", player_class.W1);          -- Wołacz (o!)
      msg = string.gsub(msg, "YOUR_RACE1", player_race.M1);            -- Mianownik (kto, co?)
      msg = string.gsub(msg, "YOUR_RACE2", player_race.D1);            -- Dopełniacz (kogo, czego?)
      msg = string.gsub(msg, "YOUR_RACE3", player_race.C1);            -- Celownik (komu, czemu?)
      msg = string.gsub(msg, "YOUR_RACE4", player_race.B1);            -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_RACE5", player_race.N1);            -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, "YOUR_RACE6", player_race.K1);            -- Miejscownik (o kim, o czym?)
      msg = string.gsub(msg, "YOUR_RACE7", player_race.W1);            -- Wołacz (o!)
      msg = string.gsub(msg, "YOUR_RACE YOUR_CLASS", "YOUR_RACE "..player_class.M1);     -- Mianownik (kto, co?)
      msg = string.gsub(msg, "ym YOUR_RACE", "ym "..player_race.N1);              -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, " jesteś YOUR_RACE", " jesteś "..player_race.N1);    -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, "YOUR_RACE", player_race.W1);                        -- Wołacz - pozostałe wystąpienia
      msg = string.gsub(msg, "ym YOUR_CLASS", "ym "..player_class.N1);            -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, "esteś YOUR_CLASS", "esteś "..player_class.N1);      -- Narzędnik (kim, czym?)
      msg = string.gsub(msg, " z Ciebie YOUR_CLASS", " z Ciebie "..player_class.M1);    -- Mianownik (kto, co?)
      msg = string.gsub(msg, " kolejny YOUR_CLASS do ", " kolejny "..player_class.M1.." do ");   -- Mianownik (kto, co?)
      msg = string.gsub(msg, " taki YOUR_CLASS", " taki "..player_class.M1);      -- Mianownik (kto, co?)
      msg = string.gsub(msg, "ako YOUR_CLASS", "ako "..player_class.M1);          -- Mianownik (kto, co?)
      msg = string.gsub(msg, " co sprowadza YOUR_CLASS", " co sprowadza "..player_class.B1);     -- Biernik (kogo, co?)
      msg = string.gsub(msg, " będę miał YOUR_CLASS", " będę miał "..player_class.B1);  -- Biernik (kogo, co?)
      msg = string.gsub(msg, "ego YOUR_CLASS", "ego "..player_class.B1);                -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_CLASS taki jak ", player_class.B1.." taki jak ");    -- Biernik (kogo, co?)
      msg = string.gsub(msg, " jak na YOUR_CLASS", " jak na "..player_class.B1);        -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_CLASS", player_class.W1);                      -- Wołacz - pozostałe wystąpienia
   end
   
   return msg;
end 

function QuestTradutor:ExpandUnitInfoFQ(msg, IsSave) 
   if(IsSave == false) then 
      msg = string.gsub(msg, "NEW_LINE", "\n");
      msg = string.gsub(msg, '\"', '"'); -- avoiding problems...
      msg = string.gsub(msg, '"', '\"');
      msg = string.gsub(msg, '\r', ''); 
      msg = string.gsub(msg, QTR_name, 'YOUR_NAME');
      msg = string.gsub(msg, string.upper(QTR_name), 'YOUR_NAME');
      msg = string.gsub(msg, QTR_race, 'YOUR_RACE');
      msg = string.gsub(msg, string.lower(QTR_race), 'YOUR_RACE');
      msg = string.gsub(msg, QTR_class, 'YOUR_CLASS');
      msg = string.gsub(msg, string.lower(QTR_class), 'YOUR_CLASS');
   else
      msg = string.gsub(msg, "\n", "NEW_LINE");
      msg = string.gsub(msg, '\"', '"'); -- avoiding problems...
      msg = string.gsub(msg, '"', '\"');
      msg = string.gsub(msg, '\r', ''); 
      msg = string.gsub(msg, QTR_name, 'YOUR_NAME');
      msg = string.gsub(msg, string.upper(QTR_name), 'YOUR_NAME');
      msg = string.gsub(msg, QTR_race, 'YOUR_RACE');
      msg = string.gsub(msg, string.lower(QTR_race), 'YOUR_RACE');
      msg = string.gsub(msg, QTR_class, 'YOUR_CLASS');
      msg = string.gsub(msg, string.lower(QTR_class), 'YOUR_CLASS');
   end 
   return msg;
end

------------------------------------------------------------- starting spells // items // mobs translation code.

local WT_TTReset = {}

local WT_colors = {
   ["c1"]={r=1,g=1,b=1,a=1.0},          -- white: Name
   ["c2"]={r=1,g=0.125,b=0.125,a=1.0},  -- red:   Requires
   ["c3"]={r=1,g=0.8235,b=0,a=1.0},     -- gold:  Description
   ["c4"]={r=0,g=1,b=0,a=1.0},          -- green: Click to learn
   ["c5"]={r=1,g=0.125,b=1,a=1.0},      -- purple:
   };


-- stolen from pfUI
local function GetItemLinkByName(name)
  for itemID = 1, 25818 do
    local itemName, hyperLink, itemQuality = GetItemInfo(itemID)
    if (itemName and itemName == name) then
      local _, _, _, hex = GetItemQualityColor(tonumber(itemQuality))
      return hex.. "|H"..hyperLink.."|h["..itemName.."]|h|r"
    end
  end
end


local function GetItemIDByName(name)
   local itemLink = GetItemLinkByName(name)
   if not itemLink then return end 
     local _, _, itemID = string.find(itemLink, "item:(%d+):%d+:%d+:%d+") 
 
   return tonumber(itemID) 
 end

 local function GetTranslatedMobInfo(name)
   for k, v in pairs(WT_NPCs) do 
      if(v["TitleEN"] == name) then 
         return k,v["Title"]
      end
    end  
 end
 


function QuestTradutor:ToolTipTranslator_IsBody(line,ind)                              -- lewy tekst
  local WT_isbody=false;
  local WT_trans="";
  if (line=="Back" or line==WT_CustomLocale.Back) then WT_trans=WT_Body.Back;
    elseif (line=="Chest" or line==WT_CustomLocale.Chest) then WT_trans=WT_Body.Chest;
    elseif (line=="Feet" or line==WT_CustomLocale.Feet) then WT_trans=WT_Body.Feet;
    elseif (line=="Finger" or line==WT_CustomLocale.Finger) then WT_trans=WT_Body.Finger;
    elseif (line=="Hands" or line==WT_CustomLocale.Hands) then WT_trans=WT_Body.Hands;
    elseif (line=="Head" or line==WT_CustomLocale.Head) then WT_trans=WT_Body.Head;
    elseif (line=="Legs" or line==WT_CustomLocale.Legs) then WT_trans=WT_Body.Legs;
    elseif (line=="Neck" or line==WT_CustomLocale.Neck) then WT_trans=WT_Body.Neck;
    elseif (line=="Shirt" or line==WT_CustomLocale.Shirt) then WT_trans=WT_Body.Shirt;
    elseif (line=="Shoulder" or line==WT_CustomLocale.Shoulder) then WT_trans=WT_Body.Shoulder;
    elseif (line=="Shoulders" or line==WT_CustomLocale.Shoulder) then WT_trans=WT_Body.Shoulder;
    elseif (line=="Trinket" or line==WT_CustomLocale.Trinket) then WT_trans=WT_Body.Trinket;
    elseif (line=="Waist" or line==WT_CustomLocale.Waist) then WT_trans=WT_Body.Waist;
    elseif (line=="Wrist" or line==WT_CustomLocale.Wrist) then WT_trans=WT_Body.Wrist;
    elseif (line=="One-Hand" or line==WT_CustomLocale.One_Hand) then WT_trans=WT_Body.One_Hand;
    elseif (line=="Two-Hand" or line==WT_CustomLocale.Two_Hand) then WT_trans=WT_Body.Two_Hand;
    elseif (line=="Main Hand" or line==WT_CustomLocale.Main_Hand) then WT_trans=WT_Body.Main_Hand;
    elseif (line=="Off Hand" or line==WT_CustomLocale.Off_Hand) then WT_trans=WT_Body.Off_Hand;
    elseif (line=="Ranged" or line==WT_CustomLocale.Ranged) then WT_trans=WT_Body.Ranged;
    elseif (line=="Melee Range" or line==WT_CustomLocale.MeleeR) then WT_trans=WT_Weapon.MeleeR;
    elseif (line=="Thrown" or line==WT_CustomLocale.Thrown) then WT_trans=WT_Body.Thrown;
    elseif (line=="Mount" or line==WT_CustomLocale.Mount) then WT_trans=WT_Body.Mount;
    elseif (line=="Relic" or line==WT_CustomLocale.Relic) then WT_trans=WT_Body.Relic;
    elseif (line=="Projectile" or line==WT_CustomLocale.Projectile) then WT_trans=WT_Body.Projectile;
  end	
  if (WT_trans~="") then
     WT_isbody=true;
  end
  if (QTRTTT_PS["mats"] == "1" and WT_isbody) then
    getglobal(QTR_GameTooltipTextLeft..ind):SetText(WT_trans);         -- podmieniamy tekst
  end
  return WT_isbody;
end


function QuestTradutor:ToolTipTranslator_IsInfoL(line,ind)                             -- lewy tekst
  local WT_isinfo=false;
  local WT_trans="";
  if (line=="Already known" or line==WT_CustomLocale.AlreadyKnown) then WT_trans=WT_InfoL.AlreadyKnown;
    elseif (line=="Binds when equipped" or line==WT_CustomLocale.BindsEq) then WT_trans=WT_InfoL.BindsEq;
    elseif (line=="Binds when picked up" or line==WT_CustomLocale.BindsPickup) then WT_trans=WT_InfoL.BindsPickup;
    elseif (line=="Cannot be disenchanted" or line==WT_CustomLocale.CannotDisench) then WT_trans=WT_InfoL.CannotDisench;
    elseif (string.sub(line,1,8)=="Classes:") then WT_trans=WT_InfoL.Classes..string.sub(line,9);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.Classes))==WT_CustomLocale.Classes) then WT_trans=WT_InfoL.Classes..string.sub(line,(strlen(WT_CustomLocale.Classes)+1));
    elseif (string.sub(line,1,6)=="Races:") then WT_trans=WT_InfoL.Races..string.sub(line,7);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.Races))==WT_CustomLocale.Races) then WT_trans=WT_InfoL.Races..string.sub(line,(strlen(WT_CustomLocale.Races)+1));
    elseif (line=="Conjured Item" or line== WT_CustomLocale.ConjuredItem) then WT_trans=WT_InfoL.ConjuredItem;
    elseif (string.sub(line,1,19)=="Cooldown remaining:") then WT_trans=WT_InfoL.CooldownRem..string.sub(line,20);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.CooldownRem))==WT_CustomLocale.CooldownRem) then WT_trans=WT_InfoL.CooldownRem..string.sub(line,(strlen(WT_CustomLocale.CooldownRem)+1));
    elseif (string.sub(line,1,10)=="Durability") then WT_trans=WT_InfoL.Durability..string.sub(line,11);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.Durability))==WT_CustomLocale.Durability) then WT_trans=WT_InfoL.Durability..string.sub(line,(strlen(WT_CustomLocale.Durability)+1));
    elseif (string.sub(line,1,9)=="Duration:") then WT_trans=WT_InfoL.Duration..string.sub(line,10);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.Duration))==strlen(WT_CustomLocale.Duration)) then WT_trans=WT_InfoL.Duration..string.sub(line,(strlen(WT_CustomLocale.Duration)+1));
    elseif (string.sub(line,1,10)=="Item Level") then WT_trans=WT_InfoL.ItemLevel..string.sub(line,11);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.ItemLevel))==WT_CustomLocale.ItemLevel) then WT_trans=WT_InfoL.ItemLevel..string.sub(line,(strlen(WT_CustomLocale.ItemLevel)+1));
    elseif (line=="This Item Begins a Quest" or line==WT_CustomLocale.ItemBegQuest) then WT_trans=WT_InfoL.ItemBegQuest;
    elseif (line=="Locked" or line==WT_CustomLocale.Locked) then WT_trans=WT_InfoL.Locked;
    elseif (line=="No sell price" or line==NoSellPrice) then WT_trans=WT_InfoL.NoSellPrice;
    elseif (line=="Quest Item" or line==WT_CustomLocale.QuestItem) then WT_trans=WT_InfoL.QuestItem;
    elseif (string.sub(line,1,9)=="Reagents:") then WT_trans=WT_InfoL.Reagents..string.sub(line,10);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.Reagents))==WT_CustomLocale.Reagents) then WT_trans=WT_InfoL.Reagents..string.sub(line,(strlen(WT_CustomLocale.Reagents)+1));
    elseif (string.sub(line,1,8)=="Requires") then WT_trans=WT_InfoL.Requires..string.sub(line,9);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.Requires))==WT_CustomLocale.Requires) then WT_trans=WT_InfoL.Requires..string.sub(line,(strlen(WT_CustomLocale.Requires)+1));
    elseif (string.sub(line,1,20)=="<Right Click to Read" or line==WT_CustomLocale.RClick) then WT_trans=WT_InfoL.RClick; 
    elseif (string.sub(line,1,20)=="<Right Click to Open" or line==WT_CustomLocale.OClick) then WT_trans=WT_InfoL.OClick;
    elseif (string.sub(line,1,19)=="<Shift-Click to buy" or line==WT_CustomLocale.SClick) then WT_trans=WT_InfoL.SClick;
    elseif (string.sub(line,1,29)=="<Shift Right Click to Socket>" or line==WT_CustomLocale.RCSocket) then WT_trans=WT_InfoL.RCSocket;
    elseif (line=="Soulbound" or line==WT_CustomLocale.Soulbound) then WT_trans=WT_InfoL.Soulbound;
    elseif (string.sub(line,1,6)=="Tools:") then WT_trans=WT_InfoL.Tools..string.sub(line,7);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.Tools))==WT_CustomLocale.Tools) then WT_trans=WT_InfoL.Tools..string.sub(line,(strlen(WT_CustomLocale.Tools)+1));
    elseif (line=="Unique" or line==WT_CustomLocale.Unique) then WT_trans=WT_InfoL.Unique;
    elseif (line=="Unique-Equipped" or line==WT_CustomLocale.UniqueEq) then WT_trans=WT_InfoL.UniqueEq;
    elseif (string.sub(line,1,7)=="Unique:") then WT_trans=WT_InfoL.UniqueC..string.sub(line, 8);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.UniqueC))==WT_CustomLocale.UniqueC) then WT_trans=WT_InfoL.UniqueC..string.sub(line, (strlen(WT_CustomLocale.UniqueC)+1));
    elseif (string.sub(line,1,16)=="Unique-Equipped:") then WT_trans=WT_InfoL.UniqueC..string.sub(line, 17);
    elseif (string.sub(line,1,strlen(WT_CustomLocale.UniqueEqC))==WT_CustomLocale.UniqueEqC) then WT_trans=WT_InfoL.UniqueC..string.sub(line, (strlen(WT_CustomLocale.UniqueEqC)+1));
    elseif (string.sub(line,1,6)=="Unique") then WT_trans=WT_InfoL.Unique..string.sub(line, 7);
    elseif (line=="Instant cast" or line==WT_CustomLocale.InstCast) then WT_trans=WT_InfoL.InstCast;
    elseif (line=="Instant" or line==WT_CustomLocale.Instant) then WT_trans=WT_InfoL.Instant;
    elseif (line=="Channeled" or line==WT_CustomLocale.Channeled) then WT_trans=WT_InfoL.Channeled;
    elseif (string.len(line)<16 and string.sub(line,-5)=="range") then
       WT_trans=string.sub(line,1,string.len(line)-5)..WT_InfoL.Range;
    elseif (string.sub(line,(strlen(WT_CustomLocale.Range)+1))==" "..WT_CustomLocale.Range) then
       WT_trans=string.sub(line,1,string.len(line)-strlen(WT_CustomLocale.Range))..WT_InfoL.Range;
  end	
  if (WT_trans~="") then
     WT_isinfo=true;
  end
  if (QTRTTT_PS["info"] == "1" and WT_isinfo) then
    getglobal(QTR_GameTooltipTextLeft..ind):SetText(WT_trans);         -- podmieniamy tekst
  end
  return WT_isinfo;
end


function QuestTradutor:GetStatFormatedStr(lineL, txt)
   local tekst = txt
   local wartab={0,0,0,0,0,0,0,0,0};             -- max. 9 liczb
   local arg0=0; 
   if(QuestTradutor.target < 2) then
      for w in string.gfind(lineL, "%d+") do
         arg0=arg0+1;
         wartab[arg0]=w;
      end;
   else
      for w in string.gmatch(lineL, "%d+") do
         arg0=arg0+1;
         wartab[arg0]=w;
      end;
   end
   if (arg0>0) then
      tekst=string.gsub(tekst, "$1", wartab[1]);
   end
   if (arg0>1) then
      tekst=string.gsub(tekst, "$2", wartab[2]);
   end
   if (arg0>2) then
      tekst=string.gsub(tekst, "$3", wartab[3]);
   end
   if (arg0>3) then
      tekst=string.gsub(tekst, "$4", wartab[4]);
   end
   if (arg0>4) then
      tekst=string.gsub(tekst, "$5", wartab[5]);
   end
   if (arg0>5) then
      tekst=string.gsub(tekst, "$6", wartab[6]);
   end
   if (arg0>6) then
      tekst=string.gsub(tekst, "$7", wartab[7]);
   end
   if (arg0>7) then
      tekst=string.gsub(tekst, "$8", wartab[8]);
   end
   if (arg0>8) then
      tekst=string.gsub(tekst, "$9", wartab[9]);
   end

   return tekst;
end
function QuestTradutor:ToolTipTranslator_IsItemStats(line,ind)                             -- lewy tekst
   local WT_isitemstat=false;
   local WT_trans="";
   local statPattern = "%d+%.?%d*"  
 
   if (string.find(line, "^++"..statPattern.." Strength$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Strength);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.Strength.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Strength);
     elseif (string.find(line, "^"..statPattern.." Armor$")) then WT_trans=QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Armor);
     elseif (string.find(line, "^"..statPattern.." "..WT_CustomLocale.Armor.."$")) then WT_trans=QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Armor);
     elseif (string.find(line, "^++"..statPattern.." Stamina$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Stamina);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.Stamina.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Stamina);
     elseif (string.find(line, "^++"..statPattern.." Agility$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Agility); 
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.Agility.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Agility); 
     elseif (string.find(line, "^++"..statPattern.." Intellect$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Intellect);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.Intellect.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Intellect);
     elseif (string.find(line, "^++"..statPattern.." Spirit$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Spirit);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.Spirit.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.Spirit);
     elseif (string.find(line, "^++"..statPattern.." Attack Power$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.AttackPower);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.AttackPower.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.AttackPower);
     elseif (string.find(line, "^++"..statPattern.." Spell Power$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.SpellPower);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.SpellPower.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.SpellPower);
     elseif (string.find(line, "^++"..statPattern.." Critical Strike$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.CriticalStrike);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.CriticalStrike.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.CriticalStrike);
     elseif (string.find(line, "^++"..statPattern.." Armor Penetration$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.ArmorPen);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.ArmorPen.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.ArmorPen);
     elseif (string.find(line, "^++"..statPattern.." Spell Penetration$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.SpellPen);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.SpellPen.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.SpellPen);
     elseif (string.find(line, "^++"..statPattern.." All Stats$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.AllStats);
     elseif (string.find(line, "^++"..statPattern.." "..WT_CustomLocale.AllStats.."$")) then WT_trans="+"..QuestTradutor:GetStatFormatedStr(line,WT_ItemStats.AllStats);
     elseif (string.find(line, ".+++"..statPattern.." .-$")) then WT_trans="$ignore"; -- ignore ALL untranslated gems/enchants.
   end	
   if (WT_trans~="") then
      WT_isitemstat=true;
   end
   if (QTRTTT_PS["isstat"] == "1" and WT_isitemstat and WT_trans~="$ignore") then 
     getglobal(QTR_GameTooltipTextLeft..ind):SetText(WT_trans);         -- podmieniamy tekst
   end
   return WT_isitemstat;
 end


function QuestTradutor:ToolTipTranslator_IsWeapon(line,ind)                            -- prawy tekst
  local WT_isweapon=false;
  local WT_trans="";
  if (line=="Axe") then WT_trans=WT_Weapon.Axe;
    elseif (line==WT_CustomLocale.Axe) then WT_trans=WT_Weapon.Axe;
    elseif (line=="Bow") then WT_trans=WT_Weapon.Bow;
    elseif (line==WT_CustomLocale.Bow) then WT_trans=WT_Weapon.Bow;
    elseif (line=="Dagger") then WT_trans=WT_Weapon.Dagger;
    elseif (line==WT_CustomLocale.Dagger) then WT_trans=WT_Weapon.Dagger;
    elseif (line=="Gun") then WT_trans=WT_Weapon.Gun;
    elseif (line==WT_CustomLocale.Gun) then WT_trans=WT_Weapon.Gun;
    elseif (line=="Mace") then WT_trans=WT_Weapon.Mace;
    elseif (line==WT_CustomLocale.Mace) then WT_trans=WT_Weapon.Mace;
    elseif (line=="Polearm") then WT_trans=WT_Weapon.Polearm;
    elseif (line==WT_CustomLocale.Polearm) then WT_trans=WT_Weapon.Polearm;
    elseif (line=="Shield") then WT_trans=WT_Weapon.Shield;
    elseif (line==WT_CustomLocale.Shield) then WT_trans=WT_Weapon.Shield;
    elseif (line=="Staff") then WT_trans=WT_Weapon.Staff;
    elseif (line==WT_CustomLocale.Staff) then WT_trans=WT_Weapon.Staff;
    elseif (line=="Sword") then WT_trans=WT_Weapon.Sword;
    elseif (line==WT_CustomLocale.Sword) then WT_trans=WT_Weapon.Sword;
    elseif (line=="Thrown") then WT_trans=WT_Weapon.Thrown;
    elseif (line==WT_CustomLocale.Thrown) then WT_trans=WT_Weapon.Thrown;
    elseif (line=="Wand") then WT_trans=WT_Weapon.Wand;
    elseif (line==WT_CustomLocale.Wand) then WT_trans=WT_Weapon.Wand;
    elseif (line=="Fist Weapon") then WT_trans=WT_Weapon.FirstW;
    elseif (line==WT_CustomLocale.FirstW) then WT_trans=WT_Weapon.FirstW;
    elseif (line=="Fishing Pole") then WT_trans=WT_Weapon.FishPole;
    elseif (line==WT_CustomLocale.FishPole) then WT_trans=WT_Weapon.FishPole;
    elseif (line=="Melee Range") then WT_trans=WT_Weapon.MeleeR;
    elseif (line==WT_CustomLocale.MeleeR) then WT_trans=WT_Weapon.MeleeR;
    elseif (line=="Arrow") then WT_trans=WT_InfoL.Arrow;
    elseif (line==WT_CustomLocale.Arrow) then WT_trans=WT_InfoL.Arrow;
    elseif (line=="Bullet") then WT_trans=WT_InfoL.Bullet;
    elseif (line==WT_CustomLocale.Bullet) then WT_trans=WT_InfoL.Bullet;
  end	
  if (WT_trans~="") then
     WT_isweapon=true;
  end
  if (QTRTTT_PS["weapon"] == "1" and WT_isweapon) then
    getglobal(QTR_GameTooltipTextRight..ind):SetText(WT_trans);         -- podmieniamy tekst
  end
  return WT_isweapon;
end


function QuestTradutor:ToolTipTranslator_IsMats(line,ind)                               -- prawy tekst
  local WT_ismats=false;
  local WT_trans="";
  if (line=="Cloth") then WT_trans=WT_Mats.Cloth;
    elseif (line==WT_CustomLocale.Cloth) then WT_trans=WT_Mats.Leather;
    elseif (line=="Leather") then WT_trans=WT_Mats.Leather;
    elseif (line==WT_CustomLocale.Leather) then WT_trans=WT_Mats.Leather;
    elseif (line=="Mail") then WT_trans=WT_Mats.Mail;
    elseif (line==WT_CustomLocale.Mail) then WT_trans=WT_Mats.Mail;
    elseif (line=="Plate") then WT_trans=WT_Mats.Plate;
    elseif (line==WT_CustomLocale.Plate) then WT_trans=WT_Mats.Plate;
  end	
  if (WT_trans~="") then
     WT_ismats=true;
  end
  if (QTRTTT_PS["mats"] == "1" and WT_ismats) then
    getglobal(QTR_GameTooltipTextRight..ind):SetText(WT_trans);         -- podmieniamy tekst
  end
  return WT_ismats;
end


function QuestTradutor:ToolTipTranslator_IsEnergy(line,ind)                             -- lewy tekst
  local WT_isener=false;
  local WT_trans="";
  if (string.sub(line,3,8)=="Energy") then WT_trans=string.sub(line,1,2)..WT_Energy.Energy;
    elseif(string.sub(line,3,(strlen(WT_CustomLocale.Energy)+2))==WT_CustomLocale.Energy) then WT_trans=string.sub(line,1,2)..WT_Energy.Energy;
    elseif (string.sub(line,4,9)=="Energy") then WT_trans=string.sub(line,1,3)..WT_Energy.Energy;
    elseif (string.sub(line,4,(strlen(WT_CustomLocale.Energy)+3))==WT_CustomLocale.Energy) then WT_trans=string.sub(line,1,3)..WT_Energy.Energy;
    elseif (string.sub(line,3,6)=="Rage") then WT_trans=string.sub(line,1,2)..WT_Energy.Rage;
    elseif (string.sub(line,3,(strlen(WT_CustomLocale.Rage)+2))==WT_CustomLocale.Rage) then WT_trans=string.sub(line,1,2)..WT_Energy.Rage;
    elseif (string.sub(line,4,7)=="Rage") then WT_trans=string.sub(line,1,3)..WT_Energy.Rage;
    elseif (string.sub(line,4,(strlen(WT_CustomLocale.Rage)+3))==WT_CustomLocale.Rage) then WT_trans=string.sub(line,1,3)..WT_Energy.Rage;
    elseif (string.sub(line,3,6)=="Mana") then WT_trans=string.sub(line,1,2)..WT_Energy.Mana;
    elseif (string.sub(line,3,(strlen(WT_CustomLocale.Mana)+2))==WT_CustomLocale.Mana) then WT_trans=string.sub(line,1,2)..WT_Energy.Mana;
    elseif (string.sub(line,4,7)=="Mana") then WT_trans=string.sub(line,1,3)..WT_Energy.Mana;
    elseif (string.sub(line,4,(strlen(WT_CustomLocale.Mana)+3))==WT_CustomLocale.Mana) then WT_trans=string.sub(line,1,3)..WT_Energy.Mana;
    elseif (string.sub(line,5,8)=="Mana") then WT_trans=string.sub(line,1,4)..WT_Energy.Mana;
    elseif (string.sub(line,5,(strlen(WT_CustomLocale.Mana)+4))==WT_CustomLocale.Mana) then WT_trans=string.sub(line,1,4)..WT_Energy.Mana;
    elseif (string.sub(line,6,9)=="Mana") then WT_trans=string.sub(line,1,5)..WT_Energy.Mana;
    elseif (string.sub(line,6,(strlen(WT_CustomLocale.Mana)+5))==WT_CustomLocale.Mana) then WT_trans=string.sub(line,1,5)..WT_Energy.Mana;
    elseif (string.sub(line,3,7)=="Focus") then WT_trans=string.sub(line,1,2)..WT_Energy.Focus;
    elseif (string.sub(line,3,(strlen(WT_CustomLocale.Focus)+2))==WT_CustomLocale.Focus) then WT_trans=string.sub(line,1,2)..WT_Energy.Focus;
    elseif (string.sub(line,4,8)=="Focus") then WT_trans=string.sub(line,1,3)..WT_Energy.Focus;
    elseif (string.sub(line,4,(strlen(WT_CustomLocale.Focus)+3))==WT_CustomLocale.Focus) then WT_trans=string.sub(line,1,3)..WT_Energy.Focus;
    elseif (string.sub(line,5,9)=="Focus") then WT_trans=string.sub(line,1,4)..WT_Energy.Focus;
    elseif (string.sub(line,5,(strlen(WT_CustomLocale.Focus)+4))==WT_CustomLocale.Focus) then WT_trans=string.sub(line,1,4)..WT_Energy.Focus;
  end	
  if (WT_trans~="") then
     WT_isener=true;
  end
  if (QTRTTT_PS["ener"] == "1" and WT_isener) then
    getglobal(QTR_GameTooltipTextLeft..ind):SetText(WT_trans);         -- podmieniamy tekst
  end
  return WT_isener;
end


function QuestTradutor:ToolTipTranslator_IsInfoR(line,ind)                             -- prawy tekst
  local WT_isinfo=false;
  local WT_trans="";
  if (line=="Channeled") then WT_trans=WT_InfoR.Channeled;
    elseif (line==WT_CustomLocale.Channeled) then WT_trans=WT_InfoR.Channeled;
    elseif (line=="Instant cast") then WT_trans=WT_InfoR.InstCast;
    elseif (line==WT_CustomLocale.InstCast) then WT_trans=WT_InfoR.InstCast;
    elseif (line=="Instant") then WT_trans=WT_InfoR.Instant;
    elseif (line==WT_CustomLocale.Instant) then WT_trans=WT_InfoR.Instant;
    elseif (line=="Idol") then WT_trans=WT_InfoR.Idol;
    elseif (line==WT_CustomLocale.Idol) then WT_trans=WT_InfoR.Idol;
    elseif (line=="Libram") then WT_trans=WT_InfoR.Libram;
    elseif (line==WT_CustomLocale.Libram) then WT_trans=WT_InfoR.Libram;
    elseif (line=="Totem") then WT_trans=WT_InfoR.Totem;
    elseif (line==WT_CustomLocale.Totem) then WT_trans=WT_InfoR.Totem;
    elseif (line=="Sigil") then WT_trans=WT_InfoR.Sigil;
    elseif (line==WT_CustomLocale.Sigil) then WT_trans=WT_InfoR.Sigil;
    elseif ((string.len(line)<16) and (string.sub(line,-5)=="range")) then
       WT_trans=string.sub(line,1,string.len(line)-5)..WT_InfoR.Range;
    elseif (string.sub(line,(strlen(WT_CustomLocale.Range)+1))==" "..WT_CustomLocale.Range) then
         WT_trans=string.sub(line,1,string.len(line)-strlen(WT_CustomLocale.Range))..WT_InfoR.Range;
  end	
  if (WT_trans~="") then
     WT_isinfo=true;
  end
  if (QTRTTT_PS["info"] == "1" and WT_isinfo) then
    getglobal(QTR_GameTooltipTextRight..ind):SetText(WT_trans);        -- podmieniamy tekst
  end
  return WT_isinfo;
end


function QuestTradutor:ToolTipTranslator_ChangeText(txt,ind)
  local color="";
  if (string.sub(txt,3,3)=="#") then                               -- jest kod koloru w tłumaczeniu
     color=string.lower(string.sub(txt,1,2));                      -- odczytaj kod tego koloru
     txt=string.sub(txt,4);                                        -- pozostaw sam tekst, bez kodu koloru
  end
  local WT_pos=string.find(txt, "|");
  if (WT_pos) then                                     -- jest znak podziału linii na lewą i prawą część
     local color2=color;
     if (string.sub(txt,3,3)=="#") then                            -- jest kod koloru dla prawego tekstu
        color=string.lower(string.sub(txt,1,2));                   -- odczytaj kod tego koloru
        txt=string.sub(txt,4);                                     -- sam tekst, bez kodu koloru
     end
     local WT_pos=string.find(txt, "|");
     local WT_rightText=string.sub(txt,WT_pos+1);
     txt=string.sub(txt,1,WT_pos-1);
     getglobal(QTR_GameTooltipTextRight..ind):SetText(WT_rightText); -- podmieniamy tekst
     if (strlen(color)>0) then                                     -- trzeba zmienić kolor linii
        getglobal(QTR_GameTooltipTextRight..ind):SetTextColor(WT_colors[color2].r,WT_colors[color2].g,WT_colors[color2].b,1);
     end
  end
  getglobal(QTR_GameTooltipTextLeft..ind):SetText(txt);              -- podmieniamy tekst
  if (strlen(color)>0) then                                        -- trzeba zmienić kolor linii
     getglobal(QTR_GameTooltipTextLeft..ind):SetTextColor(WT_colors[color].r,WT_colors[color].g,WT_colors[color].b,1);
  end                                                              -- podmieniamy kolor
end


function QuestTradutor:ToolTipTranslator_CheckMoneyFrame()
  if (getglobal(QTR_GameTooltipMoneyFrame1PrefixText)) then                            -- czy występuje sekcja 1 "Sell Price"
     if (QTR_GameTooltip:GetWidth()<160) then
        getglobal(QTR_GameTooltipMoneyFrame1PrefixText):SetText(WT_InfoL.PriceShort);  -- podmień tekst
     else
        getglobal(QTR_GameTooltipMoneyFrame1PrefixText):SetText(WT_InfoL.PriceLong);   -- podmień tekst
     end
  end
  if (getglobal(QTR_GameTooltipMoneyFrame2PrefixText)) then                            -- czy występuje sekcja 2 "Sell Price"
     if (QTR_GameTooltip:GetWidth()<160) then
        getglobal(QTR_GameTooltipMoneyFrame2PrefixText):SetText(WT_InfoL.PriceShort);  -- podmień tekst
     else
        getglobal(QTR_GameTooltipMoneyFrame2PrefixText):SetText(WT_InfoL.PriceLong);   -- podmień tekst
     end
  end
end


function QuestTradutor:ToolTipTranslator_ChangeSpell(ID)
  local WT_ln=0;                              -- licznik odczytanych linii tłumaczeń
  local WT_lines;
  if(WT_Spells[ID]) then
   WT_lines=WT_Spells[ID]["Lines"];  -- tyle jest linii z tłumaczeniem tego spella
  else
   WT_lines=QTR_FIXEDSPELL[ID]["Lines"];     -- tyle jest linii z tłumaczeniem tego spella
  end

  for i = 1, QTR_GameTooltip:NumLines(), 1 do
      local lineL=getglobal(QTR_GameTooltipTextLeft..i):GetText();   -- odczyt lewej linii
      local lineR="";
      if (getglobal(QTR_GameTooltipTextRight..i)) then
	     if (getglobal(QTR_GameTooltipTextRight..i):GetText()) then
            lineR=getglobal(QTR_GameTooltipTextRight..i):GetText();  -- odczyt prawej linii
         end
      end
      if (QuestTradutor:ToolTipTranslator_IsInfoL(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      elseif (QuestTradutor:ToolTipTranslator_IsBody(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      elseif (QuestTradutor:ToolTipTranslator_IsEnergy(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      else
         WT_ln=WT_ln+1;
         if (WT_ln>WT_lines) then                             -- oryginalnie jest więcej linii
            if (lineL~=" ") then                              -- pozostawiamy je bez zmian
                if (QTRTTT_PS["compOR"]=="1") then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..WT_Messages.original..i..":"..lineL);
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..WT_Messages.translat..i..":"..WT_Messages.nothing);
                end
            end
         else
            local tekst;
            if(WT_Spells[ID]) then
               tekst=WT_Spells[ID]["Line"..WT_ln];         -- jest kolejna linia z tłumaczeniem
            else
               tekst=QTR_FIXEDSPELL[ID]["Line"..WT_ln];
            end
            if (tekst~="$notranslate") then                   -- nie ma w tej linii zakazu tłumaczenia
                local wartab={0,0,0,0,0,0,0,0,0};             -- max. 9 liczb
                local arg0=0;
                if (getglobal(QTR_GameTooltipTextRight..i):GetText()) then
                   local lineR=getglobal(QTR_GameTooltipTextRight..i):GetText();  -- odczyt prawej linii
                   lineL=lineL.."|"..lineR;
                end
                for w in string.gmatch(lineL, "%d+") do
                   arg0=arg0+1;
                   wartab[arg0]=w;
                end;
                if (arg0>0) then
                   tekst=string.gsub(tekst, "$1", wartab[1]);
                end
                if (arg0>1) then
                   tekst=string.gsub(tekst, "$2", wartab[2]);
                end
                if (arg0>2) then
                   tekst=string.gsub(tekst, "$3", wartab[3]);
                end
                if (arg0>3) then
                   tekst=string.gsub(tekst, "$4", wartab[4]);
                end
                if (arg0>4) then
                   tekst=string.gsub(tekst, "$5", wartab[5]);
                end
                if (arg0>5) then
                   tekst=string.gsub(tekst, "$6", wartab[6]);
                end
                if (arg0>6) then
                   tekst=string.gsub(tekst, "$7", wartab[7]);
                end
                if (arg0>7) then
                   tekst=string.gsub(tekst, "$8", wartab[8]);
                end
                if (arg0>8) then
                   tekst=string.gsub(tekst, "$9", wartab[9]);
                end
                QuestTradutor:ToolTipTranslator_ChangeText(tekst,i);
                if (QTRTTT_PS["compOR"]=="1") then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..WT_Messages.original..i..":"..lineL);
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..WT_Messages.translat..i..":"..tekst);
                end
            end
        end
     end
  end
  if (WT_ln<WT_lines) then                                 -- oryginał miał mniej linii
     local nrLinii=QTR_GameTooltip:NumLines();
     for i = WT_ln+1, WT_lines, 1 do
        local tekst;
        if(WT_Spells[ID]) then
         tekst=WT_Spells[ID]["Line"..i];         -- jest kolejna linia z tłumaczeniem
        else
          tekst=QTR_FIXEDSPELL[ID]["Line"..i];
        end       -- kolejna linia z tłumaczeniem
        local kolor="c1";		                           -- kolor domyślny (biały)
        if (string.sub(tekst,3,3)=="#") then               -- jest kod koloru
           kolor=string.lower(string.sub(tekst,1,2));      -- odczytaj kod tego koloru
           tekst=string.sub(tekst,4);                      -- sam tekst, bez kodu koloru
        end
        nrLinii=nrLinii+1;
        local WT_pos=string.find(tekst, "|");
        if (WT_pos) then                                   -- jest znak podziału linii na lewą i prawą część
           local kolor2=kolor1;
           if (string.sub(tekst,3,3)=="#") then            -- jest drugi kolor dla prawego tekstu
              kolor2=string.lower(string.sub(tekst,1,2));  -- odczytaj kod tego koloru
              tekst=string.sub(tekst,4);                   -- sam tekst, bez kodu koloru
           end
           local WT_pos=string.find(tekst, "|");
           local WT_rightText=string.sub(tekst,WT_pos+1);
           local tekst=string.sub(tekst,1,WT_pos-1);
           QTR_GameTooltip:AddDoubleLine(tekst,WT_rightText,WT_colors[kolor].r,WT_colors[kolor].g,WT_colors[kolor].b,WT_colors[kolor2].r,WT_colors[kolor2].g,WT_colors[kolor2].b);
        else
           QTR_GameTooltip:AddLine(tekst,WT_colors[kolor].r,WT_colors[kolor].g,WT_colors[kolor].b,1);
        end
     end
  end

  QuestTradutor:ToolTipTranslator_CheckMoneyFrame();
  QTR_GameTooltip:Show();                         -- odśwież wyświetloną ramkę
end


function QuestTradutor:ToolTipTranslator_ChangeItem(ID)
  local WT_ln=0;                              -- licznik odczytanych linii tłumaczeń
  local WT_lines;
  if(WT_Items[ID]) then
   WT_lines =WT_Items[ID]["Lines"];       -- tyle jest linii z tłumaczeniem tego Itemu
  else
   WT_lines =QTR_FIXEDITEM[ID]["Lines"]; 
  end

  for i = 1, QTR_GameTooltip:NumLines(), 1 do                        -- najpierw lecimy po liniach oryginału
      local lineL=getglobal(QTR_GameTooltipTextLeft..i):GetText();  -- odczyt lewej linii
      local lineR="";
      if (getglobal(QTR_GameTooltipTextRight..i)) then
	     if (getglobal(QTR_GameTooltipTextRight..i):GetText()) then
            lineR=getglobal(QTR_GameTooltipTextRight..i):GetText(); -- odczyt prawej linii
         end
      end 
      if (QuestTradutor:ToolTipTranslator_IsInfoL(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      elseif (QuestTradutor:ToolTipTranslator_IsBody(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      elseif (QuestTradutor:ToolTipTranslator_IsEnergy(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      elseif (QuestTradutor:ToolTipTranslator_IsItemStats(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      else
         WT_ln=WT_ln+1;                                       -- kolejna linia z tłumaczeniem
         if (WT_ln>WT_lines) then                             -- oryginalnie jest więcej linii
            if (lineL~=" ") then                              -- pozostawiamy je bez zmian
                if (QTRTTT_PS["compOR"]=="1") then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..WT_Messages.original..i..":"..lineL);
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..WT_Messages.translat..i..":"..WT_Messages.nothing);
                end
            end;
         else
            local tekst;          -- jest kolejna linia z tłumaczeniem
            if(WT_Items[ID]) then
               tekst=WT_Items[ID]["Line"..WT_ln];
            else
               tekst=QTR_FIXEDITEM[ID]["Line"..WT_ln];
            end
            if (tekst~="$notranslate") then                   -- nie ma w tej linii zakazu tłumaczenia
                local wartab={0,0,0,0,0,0,0,0,0};             -- max. 9 liczb
                local arg0=0;
                if (getglobal(QTR_GameTooltipTextRight..i):GetText()) then
                   local lineR=getglobal(QTR_GameTooltipTextRight..i):GetText();  -- odczyt prawej linii
                   lineL=lineL.."|"..lineR;
                end
                for w in string.gmatch(lineL, "%d+") do
                   arg0=arg0+1;
                   wartab[arg0]=w;
                end;
                if (arg0>0) then
                   tekst=string.gsub(tekst, "$1", wartab[1]);
		        end
                if (arg0>1) then
                   tekst=string.gsub(tekst, "$2", wartab[2]);
                end
                if (arg0>2) then
                   tekst=string.gsub(tekst, "$3", wartab[3]);
                end
                if (arg0>3) then
                   tekst=string.gsub(tekst, "$4", wartab[4]);
                end
                if (arg0>4) then
                   tekst=string.gsub(tekst, "$5", wartab[5]);
                end
                if (arg0>5) then
                   tekst=string.gsub(tekst, "$6", wartab[6]);
                end
                if (arg0>6) then
                   tekst=string.gsub(tekst, "$7", wartab[7]);
                end
                if (arg0>7) then
                   tekst=string.gsub(tekst, "$8", wartab[8]);
                end
                if (arg0>8) then
                   tekst=string.gsub(tekst, "$9", wartab[9]);
                end
                if (ID=="6948") then           -- Hearthstone
                   local WTR_enddot=string.find(lineL,"  ",21);
                   local WTR_currhome=string.sub(lineL,21,WTR_enddot-2);
                   tekst=string.gsub(tekst, "$homelocation", WTR_currhome);
                end
                QuestTradutor:ToolTipTranslator_ChangeText(tekst,i);
                if (QTRTTT_PS["compOR"]=="1") then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..WT_Messages.original..i..":"..lineL);
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..WT_Messages.translat..i..":"..tekst);
                end
            end
         end
      end
  end
  if (WT_ln<WT_lines) then                                 -- oryginał miał mniej linii lub wyczyszczono linie
     local nrLinii=QTR_GameTooltip:NumLines();
     for i = WT_ln+1, WT_lines, 1 do
        local tekst;
        if(WT_Items[ID]) then
            tekst=WT_Items[ID]["Line"..i];
         else
            tekst=QTR_FIXEDITEM[ID]["Line"..i];
         end              -- kolejna linia z tłumaczeniem
        local kolor="c1";		                           -- kolor domyślny (biały)
        if (string.sub(tekst,3,3)=="#") then               -- jest kod koloru
           kolor=string.lower(string.sub(tekst,1,2));      -- odczytaj kod tego koloru
           tekst=string.sub(tekst,4);                      -- sam tekst, bez kodu koloru
        end
        nrLinii=nrLinii+1;
        local WT_pos=string.find(tekst, "|");  
        if (WT_pos) then                                   -- jest znak podziału linii na lewą i prawą część
           local kolor2=kolor1;
           if (string.sub(tekst,3,3)=="#") then            -- jest drugi kolor dla prawego tekstu
              kolor2=string.lower(string.sub(tekst,1,2));  -- odczytaj kod tego koloru
              tekst=string.sub(tekst,4);                   -- sam tekst, bez kodu koloru
           end
           local WT_pos=string.find(tekst, "|");
           local WT_rightText=string.sub(tekst,WT_pos+1);
           local tekst=string.sub(tekst,1,WT_pos-1);
           QTR_GameTooltip:AddDoubleLine(tekst,WT_rightText,WT_colors[kolor].r,WT_colors[kolor].g,WT_colors[kolor].b,WT_colors[kolor2].r,WT_colors[kolor2].g,WT_colors[kolor2].b);
        else
           QTR_GameTooltip:AddLine(tekst,WT_colors[kolor].r,WT_colors[kolor].g,WT_colors[kolor].b,1);
           if (nrLinii==1) then                          -- linia nr 1: trzeba większą czcionką
           else
           end
        end
     end
  end 
  QuestTradutor:ToolTipTranslator_CheckMoneyFrame()
  QTR_GameTooltip:Show();                                  -- odśwież wyświetloną ramkę
end


function QuestTradutor:ToolTipTranslator_TryTranslation()
  for i = 1, QTR_GameTooltip:NumLines(), 1 do                        -- lecimy po liniach oryginału

     local lineL=getglobal(QTR_GameTooltipTextLeft..i):GetText();  -- odczyt lewej linii
      local lineR="";
      if (getglobal(QTR_GameTooltipTextRight..i)) then
	     if (getglobal(QTR_GameTooltipTextRight..i):GetText()) then
            lineR=getglobal(QTR_GameTooltipTextRight..i):GetText(); -- odczyt prawej linii
         end
      end 
      if (QuestTradutor:ToolTipTranslator_IsInfoL(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      elseif (QuestTradutor:ToolTipTranslator_IsBody(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      elseif (QuestTradutor:ToolTipTranslator_IsEnergy(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      elseif (QuestTradutor:ToolTipTranslator_IsItemStats(lineL,i)==true) then
         if (lineR~="") then
            if (QuestTradutor:ToolTipTranslator_IsWeapon(lineR,i)==false) then
               if (QuestTradutor:ToolTipTranslator_IsMats(lineR,i)==false) then
                  QuestTradutor:ToolTipTranslator_IsInfoR(lineR,i);
               end
            end
         end
      end
   end
   QuestTradutor:ToolTipTranslator_CheckMoneyFrame()
   QTR_GameTooltip:Show();                                  -- odśwież wyświetloną ramkę
end

function QuestTradutor:ToolTipTranslator_ResetChangedTooltipValues()
   for i = 1, table.getn(WT_TTReset), 1 do
      if(getglobal(QTR_GameTooltipTextLeft..WT_TTReset[i]["ID"])) then
         getglobal(QTR_GameTooltipTextLeft..WT_TTReset[i]["ID"]):SetFont(WT_TTReset[i]["itFont"], WT_TTReset[i]["itSize"]) 
      end
   end
   WT_TTReset = {};

   for i = 1, 2, 1 do -- lol why not
      if(_G["ShoppingTooltip"..i]) then
         HideUIPanel(_G["ShoppingTooltip"..i]); -- for some weird reason, this frame stays open even after the item frame on shop gets closed.
      end
   end
   
   
end


function QuestTradutor:ToolTipTranslator_ShowTranslationG()
   QTR_GameTooltip = GameTooltip;
   QTR_GameTooltipTextLeft = "GameTooltipTextLeft"
   QTR_GameTooltipTextLeft1 = "GameTooltipTextLeft1"
   QTR_GameTooltipTextRight = "GameTooltipTextRight"
   QTR_GameTooltipMoneyFrame1PrefixText = "GameTooltipMoneyFrame1PrefixText"
   QTR_GameTooltipMoneyFrame2PrefixText = "GameTooltipMoneyFrame1PrefixText"
   QuestTradutor:ToolTipTranslator_ShowTranslation()
end
function QuestTradutor:ToolTipTranslator_ShowTranslationR()
   QTR_GameTooltip = ItemRefTooltip;
   QTR_GameTooltipTextLeft = "ItemRefTooltipTextLeft"
   QTR_GameTooltipTextLeft1 = "ItemRefTooltipTextLeft1"
   QTR_GameTooltipTextRight = "ItemRefTooltipTextRight"
   QTR_GameTooltipMoneyFrame1PrefixText = "ItemRefTooltipMoneyFrame1PrefixText"
   QTR_GameTooltipMoneyFrame2PrefixText = "ItemRefTooltipMoneyFrame1PrefixText"
   QuestTradutor:ToolTipTranslator_ResetChangedTooltipValues()
   QuestTradutor:ToolTipTranslator_ShowTranslation()
end
function QuestTradutor:ToolTipTranslator_ShowTranslationA()
   QTR_GameTooltip = AtlasLootTooltip;
   QTR_GameTooltipTextLeft = "AtlasLootTooltipTextLeft"
   QTR_GameTooltipTextLeft1 = "AtlasLootTooltipTextLeft1"
   QTR_GameTooltipTextRight = "AtlasLootTooltipTextRight"
   QTR_GameTooltipMoneyFrame1PrefixText = "AtlasLootTooltipMoneyFrame1PrefixText"
   QTR_GameTooltipMoneyFrame2PrefixText = "AtlasLootTooltipMoneyFrame1PrefixText"
   QuestTradutor:ToolTipTranslator_ShowTranslation()
end

function QuestTradutor:ToolTipTranslator_ShowTranslationS(i)
   QTR_GameTooltip = _G["ShoppingTooltip"..i];
   QTR_GameTooltipTextLeft = "ShoppingTooltip"..i.."TextLeft"
   QTR_GameTooltipTextLeft1 = "ShoppingTooltip"..i.."TextLeft1"
   QTR_GameTooltipTextRight = "ShoppingTooltip"..i.."TextRight"
   QTR_GameTooltipMoneyFrame1PrefixText = "ShoppingTooltip"..i.."MoneyFrame1PrefixText"
   QTR_GameTooltipMoneyFrame2PrefixText = "ShoppingTooltip"..i.."MoneyFrame2PrefixText"
   QuestTradutor:ToolTipTranslator_ShowTranslation()
end


function QuestTradutor:ToolTipTranslator_ShowTranslation()
  
   if (QTRTTT_PS["active"]=="1") then
      if (QTRTTT_PS["try"]=="1") then
         QuestTradutor:ToolTipTranslator_TryTranslation();
      end
      if(QTRTTT_PS["questHelp"]=="1") then  
         local itemID = GetItemIDByName(getglobal(QTR_GameTooltipTextLeft1):GetText());
         if(itemID) then
            if(WT_QuestItemTemp[tostring(itemID)]) then
               local itR,itG,itB,itA = getglobal(QTR_GameTooltipTextLeft1):GetTextColor();
               local itFont, itFontSize = getglobal(QTR_GameTooltipTextLeft1):GetFont();
               QTR_GameTooltip:AddLine(" ",0,0,0);
               QTR_GameTooltip:AddLine(WT_QuestItemTemp[tostring(itemID)]["Title"],itR,itG,itB); 

               for itt = 1, QTR_GameTooltip:NumLines(), 1 do
                  if(getglobal(QTR_GameTooltipTextLeft..itt):GetText() == WT_QuestItemTemp[tostring(itemID)]["Title"]) then 
                     local storedFont, storedSize = getglobal(QTR_GameTooltipTextLeft..itt):GetFont();
                     getglobal(QTR_GameTooltipTextLeft..itt):SetFont(itFont, itFontSize);
                     local numba = table.getn(WT_TTReset)+1;
                     WT_TTReset[numba]={}
                     WT_TTReset[numba]["ID"] = itt;
                     WT_TTReset[numba]["itFont"] = storedFont;
                     WT_TTReset[numba]["itSize"] = storedSize;
                  end
               end
            end
            if (QTRTTT_PS["showID"]=="1") then
               if(QTRTTT_PS["questHelp"]=="0" or not WT_QuestItemTemp[tostring(itemID)]) then
                  QTR_GameTooltip:AddLine(" ",0,0,0);  
               end                         -- dodaj odstęp i itemID
               if (QTRTTT_PS["try"]=="1") then
                  QTR_GameTooltip:AddDoubleLine("Item ID: "..itemID,"try",0,1,1,0,1,1);
               else
                  QTR_GameTooltip:AddLine("Item ID: "..itemID,0,1,1);
               end
               QTR_GameTooltip:Show();                                       -- odśwież wyświetloną ramkę
            end
            QTR_GameTooltip:Show();   
         else 
           local targetNPC, wt_UnitName = GetTranslatedMobInfo(getglobal(QTR_GameTooltipTextLeft1):GetText())
           if(wt_UnitName) then  
               local npR, npG, npB, npA = getglobal(QTR_GameTooltipTextLeft1):GetTextColor(); 
               local itFont, itFontSize = getglobal(QTR_GameTooltipTextLeft1):GetFont();
               QTR_GameTooltip:AddLine(" ",0,0,0);                           
               QTR_GameTooltip:AddLine(wt_UnitName, npR, npG, npB);
               for itt = 1, QTR_GameTooltip:NumLines(), 1 do
                  if(getglobal(QTR_GameTooltipTextLeft..itt):GetText() == wt_UnitName) then 
                     local storedFont, storedSize = getglobal(QTR_GameTooltipTextLeft..itt):GetFont();
                     getglobal(QTR_GameTooltipTextLeft..itt):SetFont(itFont, itFontSize);
                     local numba = table.getn(WT_TTReset)+1;
                     WT_TTReset[numba]={}
                     WT_TTReset[numba]["ID"] = itt;
                     WT_TTReset[numba]["itFont"] = storedFont;
                     WT_TTReset[numba]["itSize"] = storedSize;
                  end
               end 

               if (QTRTTT_PS["showID"]=="1") then 
                  QTR_GameTooltip:AddLine("NPC ID: "..targetNPC,0,1,1);
               end

               QTR_GameTooltip:Show();
            end
         end 
      end
   end
end