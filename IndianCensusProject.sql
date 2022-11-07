use projects;

select * from dataset_1;
select * from dataset_2;

-- No of rows available

select count(*) from dataset_1;
select count(*) from dataset_2;


-- Filter data with MAHARASHTRA AND KERALA

select * from dataset_1 where [State ] in ('Maharashtra' , 'Kerala');


-- Total population

select SUM(Population ) as Total_Population from dataset_2;

-- state wise population 

  select state,SUM(Population) as state_population from dataset_2 
   where State <> '#N/A'  
  group by State ORDER BY  state_population DESC ;



  --- Average growth 

  select AVG(Growth)*100 as average_growth from dataset_1;

  --Average growth by state

  select [State ],AVG(Growth)*100 as avg_growth_state from dataset_1 group by [State ];

  --maximum , Minumun , Average sex ratio 


  select Max(sex_ratio) as maximum_sexratio , min( sex_ratio) as minimum_sexratio ,
  AVG(sex_ratio) as avg_sexratio from dataset_1;

  -- state having sex ratio above average 

  select [State ],round(AVG(sex_ratio),0) as avg_sexratio from dataset_1 
  group by [State ]  having round(AVG(sex_ratio),0) > (select AVG(sex_ratio) from dataset_1);



    -- state having sex ratio Below average 



  select [State ],round(AVG(sex_ratio),0) as avg_sexratio from dataset_1 
  group by [State ]  having round(AVG(sex_ratio),0) < (select AVG(sex_ratio) from dataset_1) ;



  --  top 5 state  having  most sex ratio

  select top 5 [State ],avg(sex_ratio) state_sexratio from dataset_1 group by [State ] order by state_sexratio desc;

  -- minimum , maximum and average Literacy rate

 select Max(Literacy) as maximum_literacy , min( Literacy) as minimum_literacy ,
  AVG(Literacy) as avg_literacy from dataset_1;


  -- state having more than 90% Literacy 

  select [State ],AVG(literacy)  as avg_literacy from dataset_1 group by [State ] having AVG(Literacy) > 90;


  -- top litreated state using temporary table

  drop table  if exists #temptable
  create table #temptable(
  state nvarchar(255),
  top_state float
  )

  insert into #temptable
  select [State ] ,AVG(literacy) from dataset_1 group by [State ] ;

  select top 3 * from #temptable order by top_state desc;


    drop table  if exists #temptable_1
  create table #temptable_1(
  state nvarchar(255),
  low_state float
  )

  insert into #temptable_1
  select [State ] ,AVG(literacy) from dataset_1 group by [State ] ;

  select top 3 * from #temptable order by top_state ;




  --union  operartor

  select * from (select top 3 * from #temptable order by #temptable.top_state desc) a

  union 

  select * from (select top 3 * from #temptable_1 order by low_state ) b;




  --  joining both tables and making temporary table

  drop table if exists #joiningtable
  create table #joiningtable(
  district nvarchar (255),
  State nvarchar(255),
  Sex_Ratio float,
  Population float)
  insert into #joiningtable
  select d1.district , d1.[State ] ,d1.sex_ratio ,  d2.Population 
  from dataset_1 d1
  inner join dataset_2 d2 on d1.District=d2.District ;

  select * from #joiningtable;

-- population of male and female
-- formaula to find count of male and female
-- male =population/(1+sex_ratio)   , female = (population * sex_ratio)/(1 + sex_ratio)

select fm.district , fm.state ,fm.Population  population, 
round(fm.population/(1+fm.sex_ratio),0) Male , 
round((fm.population * fm.sex_ratio )/(1+fm.sex_ratio),0) Female
from
(select a.district , a.state ,a.sex_ratio/1000 sex_ratio ,b.population from 
dataset_1 a inner join dataset_2 b
on a.District=b.District) fm


 -- literate people and illiterate people counting state wise


 select l.[State ], sum(l.Population) as Total_Population ,round(sum((l.Literacy/100)*(l.population)),0) literate_people ,
 round(sum((1-(l.Literacy/100))*(l.population)),0) illiterate_people
 from
 (select a.District ,a.[State ] ,a.Literacy ,b.Population from
 dataset_1 a  inner join dataset_2 b
 on a.District = b.District) l
 group by l.[State ];



 -- Previous population vs current_population state_wise
 drop table if exists #populationtable
 create table #populationtable(
 state nvarchar(255),
 previous_population int,
 current_population int, 
 growth float)
 insert into #populationtable
 select f.state ,sum(f.previous_population) ,sum(f.Current_Population) ,sum(f.growth) growth from
 (select p.growth ,p.district ,p.state ,round(p.population/(1+p.growth) ,0)previous_population ,p.population Current_Population from (select a.district , a.state , b.population ,a.growth from
 dataset_1 a inner join dataset_2 b on a.District = b.District) p) f
 group by f.state;


 ---- Area Vs Population

 select (q.Total_AreaKm/q.total_previous_population) previous_population_Area  , 
 (q.Total_AreaKm/q.total_current_population) Current_population_Area from
(select m.*,n.Total_AreaKM from 
 (select '1' as keyy,a.* from
 (select SUM(previous_population) total_previous_population,SUM(current_population) total_current_population
 from #populationtable) a) m
 inner join 
 (select '1' as keyy , b.* from
 (select sum(Area_km2) Total_AreaKM from dataset_2 ) b)n 
 
 on  m.keyy = n.keyy) q ;

 -- area per population has reduced for current census population


 -- top 5 district in each state (Using Windo function)

 select s.* from
 (select district , state ,literacy ,
 RANK() over(partition by state order by literacy desc) rnk from dataset_1) s 
 where s.rnk in (1,2,3);





   
  
