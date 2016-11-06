function res  = Turtle_Commodity_Wheat(files,high_breakout,low_breakout,exit_long,exit_short)

files = 'wheat_daily';
path  = 'C:\Akshay\Investing Strategies\NewBox\';

high_breakout=30;
low_breakout=30;

exit_long= 10;
exit_short=10;


filend = '.csv';
output_arr = {};

filename = [path files filend];

%try
p = textread(filename, '%s', 'delimiter', '\n','whitespace', '');
index_in = [];
date_in  = [];
open_in = [];
high_in = [];
low_in = [];
close_in = [];
turnover_in =[];
               
for jjj=2:length(p) 
    jjj
    h = regexp(p{jjj},',');
    index = p{jjj}(1:h(1)-1);
    date_in_str =  p{jjj}(h(1)+1:h(2)-1);
    open_in_str =  p{jjj}(h(2)+1:h(3)-1);
    high_in_str =  p{jjj}(h(3)+1:h(4)-1);
    low_in_str =   p{jjj}(h(4)+1:h(5)-1);
    close_in_str = p{jjj}(h(5)+1:h(6)-1);
    turnover_in_str =  p{jjj}(h(6)+1:end);
    
    
    index_in = [index_in; str2num(index) ];
    date_in  = [date_in;date_in_str ];
    open_in  = [open_in ; str2num(p{jjj}(h(2)+1:h(3)-1))];
    high_in  = [high_in ; str2num(p{jjj}(h(3)+1:h(4)-1))];
    low_in   = [low_in ; str2num(p{jjj}(h(4)+1:h(5)-1))];
    close_in = [close_in ; str2num(p{jjj}(h(5)+1:h(6)-1))];
    turnover_in = [turnover_in ; str2num(p{jjj}(h(6)+1:end))];
    
end

 
index = index_in;          
date  = str2num(date_in);
open = open_in;
high = high_in;
low = low_in;
close = close_in;
turnover = turnover_in;


Long_Signal = 0; 
Short_Signal = 0;
Trd_Status = 0;
Trd_Ent_Price = 0;
Trd_Ext_Price = 0;
Trd_Ent_Date = 0; 
Trd_Ext_Date = 0;
Trd_RowNo = 2;
Trd_PL = 0;
Trd_Ent_Index = 0;
Trd_Ext_Index = 0;
Trd_Cum_PL = 0;
trd_arr = {};
Trd_Status = 0;
TR=0;
PDN=0;
N=0;
M1=0;
M2=0;
TR1=0;
SL=0;
for i = 2: length(index)- 20
    M1(i,1)= max(high(i,1)-low(i,1),high(i,1)-close(i-1,1));
    M2(i,1)= (close(i-1,1)-low(i,1));
    TR(i,1)=max(M1(i,1),M2(i,1));
end
TR

N(high_breakout+1,1)=mean(TR(2:high_breakout+1));

for j = high_breakout+2: length(index)- 20
    N(j,1)= (19*N(j-1,1)+TR(j,1))/20;
end


for i = high_breakout+2: length(index)- 20
    i
   
    if(max(high(i-high_breakout-1:i-1)) < open(i))
        High_Array(i,1)=max(high(i-high_breakout-1:i-1));
        Long_Signal = 1;
    end

         
    if (min(low(i-low_breakout:i-1)) > open(i))
        Low_Array(i,1)=min(low(i-low_breakout-1:i-1));
        Short_Signal = 1;
    end          
    
        if (Long_Signal == 1 && (Trd_Status == 0))
                Trd_Status = 1;
                Trd_Type = 'LONG';
                Trd_Ent_Price =  open(i);
                SL = 1*N(i);
                Trd_Ent_Date  =  date(i);
                Trd_Ent_Index= index(i);
                Short_Signal = 0;
                Long_Signal = 0;
        end


         if (Short_Signal == 1 && (Trd_Status == 0))
            Trd_Status = -1;
            Trd_Type = 'Short';
            Trd_Ent_Price =  open(i);
            SL = 1*N(i);
            Trd_Ent_Date  =  date(i);
            Trd_Ent_Index= index(i);
            Long_Signal = 0;
            Short_Signal = 0;
        end
    
    
    if (Trd_Status == 1)
           if ((min(low(i-exit_long:i-1))> open(i)) || (Trd_Ent_Price-SL)>open(i))
           %if ((min(low(i-exit_long:i-1))> open(i)))
    
                Trd_Status = 0;

                %Worksheets(SheetName).Range("L" & RowNo).Value = "LONG UNWIND"
                Trd_Ext_Price = open(i);
                Trd_Ext_Date  = date(i);
                Trd_Ext_Index = index(i);
                Trd_PL = (Trd_Ext_Price - Trd_Ent_Price);
                Trd_Cum_PL = Trd_Cum_PL + Trd_PL;
                trd_arr = [trd_arr;{Trd_Ent_Index Trd_Ent_Date Trd_Ent_Price Trd_Ext_Index Trd_Ext_Date Trd_Ext_Price Trd_PL Trd_Cum_PL Trd_Type SL}];

                % re initialize parameters            
                Trd_Ent_Price = 0; Trd_Ent_Date = 0; Trd_Ent_Index=0;
                Trd_Ext_Price = 0; Trd_Ext_Date = 0; Trd_Ext_Index;
                Trd_PL = 0; Trd_Type = 0; SL=0;
                Long_Signal = 0;
           end
    end
    
            
      if (Trd_Status == -1)
           if ((max(low(i-exit_short:i-1))< open(i)) || (Trd_Ent_Price+SL)<open(i))
           
           %if ((max(low(i-exit_short:i-1))< open(i)))
            Trd_Status = 0;
            Trd_Ext_Price =  open(i);
            Trd_Ext_Date  =  date(i);
            Trd_Ext_Index = index(i);
            Trd_PL = (Trd_Ent_Price - Trd_Ext_Price) ;
            Trd_Cum_PL = Trd_Cum_PL + Trd_PL;
            trd_arr = [trd_arr;{Trd_Ent_Index Trd_Ent_Date Trd_Ent_Price Trd_Ext_Index Trd_Ext_Date Trd_Ext_Price Trd_PL Trd_Cum_PL Trd_Type SL}];
            % re initialize parameters            
            Trd_Ent_Price = 0; Trd_Ent_Date = 0; Trd_Ent_Index=0;
            Trd_Ext_Price = 0; Trd_Ext_Date = 0; Trd_Ext_Index;
            Trd_PL = 0; Trd_Type = 0; SL=0;
            Short_Signal = 0;
           end 
      end
    
       
end


PnL = Trd_Cum_PL
notrades = size(trd_arr,1)

header = {'Trd_Ent_Index'  'Trd_Ent_Date' 'Trd_Ent_Price'  'Trd_Ext_index' 'Trd_Ext_Date' 'Trd_Ext_Price' 'Trd_PL' 'Trd_Cum_PL' 'Trd_Type' 'SL'};
trd_arr = [header;trd_arr];
filename = 'output_turt_wheat.xlsx';
xlswrite(filename,trd_arr)

    
 input = {'index' 'date' 'open' 'high' 'low' 'close' 'turnover'}
 for i = 1 : length(index)
    input = [input ;{index(i) date(i) open(i) high(i) low(i) close(i) turnover(i)}];
 end

filename = 'input_turt_wheat.xlsx'
xlswrite(filename,input)
end

