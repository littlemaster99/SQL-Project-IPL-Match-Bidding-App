use ipl;
# Questions – Write SQL queries to get data for the following requirements:

# 1.Show the percentage of wins of each bidder in the order of highest to lowest percentage.
select * from ipl_bidding_details;
select bidder_id,(sum(if(bid_status='won',1,0))/count(bid_status))*100 as percentage 
from ipl_bidding_details group by bidder_id order by percentage desc;

-- 2.Display the number of matches conducted at each stadium with the stadium name and city.
select * from ipl_stadium;
select * from ipl_match_schedule;
select  stadium_name, city, count(match_id) as match_count 
from ipl_match_schedule iplms join ipl_stadium ipls
on iplms.STADIUM_ID = ipls.STADIUM_ID
group by STADIUM_NAME,city;

-- 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?
with table1 as(
select stadium_id, sum(if(toss_winner=match_winner,1,0)) as winning_count, count(iplm.MATCH_ID) as total_matches
from ipl_match iplm join ipl_match_schedule iplms
on iplm.MATCH_ID=iplms.MATCH_ID
group by stadium_id
order by stadium_id)
select stadium_id,winning_count,total_matches, round((winning_count/total_matches)*100,2) as percent
from table1;

-- 4.	Show the total bids along with the bid team and team name.
select count(bid_team) as Total_bids,Bid_team,TEAM_NAME from ipl_bidding_details join ipl_team 
on ipl_bidding_details.bid_team = ipl_team.Team_id group by bid_team;

# 5.	Show the team id who won the match as per the win details.
select * from ipl_match;
select if(match_winner=1,team_id1,team_id2) as team_id, win_details from ipl_match
order by team_id;


# 6.	Display total matches played, total matches won and total matches lost by the team along with its team name.

select * from ipl_stadium;
select * from ipl_stadium;
select its.team_id,team_name,sum(MATCHES_PLAYED),sum(MATCHES_WON),sum(MATCHES_LOST) 
from ipl_team_standings its join ipl_team it
on its.team_id =it.team_id
 group by its.team_id;
 
-- 7.Display the bowlers for the Mumbai Indians team.

select Player_name from ipl_player where player_id in (
select player_id from ipl_team_players where PLAYER_ROLE like '%bowler%' and team_id = (
select team_id from ipl_team where Team_name like '%mumbai%')); 

-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 
# all-rounders in descending order.

select itp.Team_id,Team_name,count(itp.team_id) as no_of_allrounders from ipl_team_players itp join ipl_team it on itp.team_id = it.team_id
where PLAYER_ROLE = 'all-rounder' 
group by itp.TEAM_ID 
having no_of_allrounders >4
order by no_of_allrounders desc;

-- 9.Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in
# M. Chinnaswamy Stadium bidding year-wise.
 # Note the total bidders’ points in descending order and the year is bidding year.
 #             Display columns: bidding status, bid date as year, total bidder’s points
 
select ibd.*,year(BID_DATE),TOTAL_POINTS from ipl_bidding_details ibd  join ipl_bidder_points ibp
on ibd.BIDDER_ID = ibp.BIDDER_ID
where bid_team = (
select Team_id from ipl_team where team_name like '%chennai%') and SCHEDULE_ID in (
select SCHEDULE_ID from ipl_match_schedule where STADIUM_ID = (
select STADIUM_ID from ipl_stadium where STADIUM_NAME like '%chinna%')) and BID_STATUS = 'won';

/*10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
Note 
1. use the performance_dtls column from ipl_player to get the total number of wickets
 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
3.	Do not use joins in any cases.
4.	Display the following columns teamn_name, player_name, and player_role.*/


select * from ipl_player;

select TEAM_NAME,PLAYER_NAME,PLAYER_ROLE from (
select temp.*,player_role,TEAM_NAME, dense_rank () over(order by wickets desc) as ranks from (
select *, cast(substring_index(substring_index(performance_dtls,' ',3),'-',-1)as float) as wickets from ipl_player) temp 
join ipl_team_players itp on itp.player_id = temp.player_id
join ipl_team it on itp.TEAM_ID = it.TEAM_ID) temp1 where PLAYER_ROLE in ('all-rounder','bowler') and ranks <=5 order by 1,2;

-- 11.show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

with temp as (select BIDDER_ID,BID_TEAM,if(TOSS_WINNER = 1,team_id1,team_id2) as TW_team
from ipl_match im join ipl_match_schedule ims on im.MATCH_ID = ims.MATCH_ID
join ipl_bidding_details ibd on ims.SCHEDULE_ID = ibd.SCHEDULE_ID)

select bidder_id,sum(if(bid_team = tw_team,1,0))/count(bid_team)*100 as percentage_of_TW 
from temp group by bidder_id order by percentage_of_tw desc;


/*  12. find the IPL season which has min duration and max duration.
Output columns should be like the below:
 Tournment_ID, Tourment_name, Duration column, Duration*/
 

 select TOURNMT_ID,TOURNMT_NAME,concat(date(from_date),' - ',date(to_date)) as duration_column, datediff(to_date,from_date)as duration 
 from ipl_tournament where datediff(to_date,from_date) in ((select max(datediff(to_date,from_date))as duration 
 from ipl_tournament ),(select min(datediff(to_date,from_date))as duration 
 from ipl_tournament));
 
 /*
13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. 
sort the results based on total points in descending order and month-wise in ascending order.
Note: Display the following columns:
1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
Only use joins for the above query queries.
*/

select distinct ibd.bidder_id,BIDDER_NAME,year(BID_DATE) as year,monthname(bid_date) as month,TOTAL_POINTS
from ipl_bidding_details ibd join ipl_bidder_points ibp
on ibd.BIDDER_ID = ibp.BIDDER_ID join
ipl_bidder_details ibrd on ibd.BIDDER_ID = ibrd.BIDDER_ID
where year(BID_DATE) = 2017 order by TOTAL_POINTS desc, month asc;

-- 14.Write a query for the above question using sub queries by having the same constraints as the above question.
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select bidder_id, (select bidder_name from ipl_bidder_details where ipl_bidder_details.bidder_id=ipl_bidding_details.bidder_id) as bidder_name,
year(bid_date) as `year`, monthname(bid_date) as `month`, 
(select total_points from ipl_bidder_points where ipl_bidder_points.bidder_id=ipl_bidding_details.bidder_id) as total_points from ipl_bidding_details
where year(bid_date)=2017
group by bidder_id,bidder_name,year,month,total_points
order by total_points desc;

-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be:
-- like:
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;


select temp1.*,BIDDER_NAME as Highest_3_bidders from (select BIDDER_ID,rank() over(order by TOTAL_POINTS desc) as ranks, TOTAL_POINTS
from ipl_bidder_points) temp1 join ipl_bidder_details ibd
on ibd.BIDDER_ID = temp1.BIDDER_ID
 where  ranks<=3
 union
select temp1.*,BIDDER_NAME as Lowest_3_bidders from (select BIDDER_ID,rank() over(order by TOTAL_POINTS desc) as ranks, TOTAL_POINTS
from ipl_bidder_points)temp1 join ipl_bidder_details ibd
on ibd.BIDDER_ID = temp1.BIDDER_Id
where  ranks in (select * from(select rank() over(order by TOTAL_POINTS desc) as ranks
from ipl_bidder_points order by ranks desc limit 3)temp);

/*16.	Create two tables called Student_details and Student_details_backup.

Table 1: Attributes 							Table 2: Attributes
Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

Feel free to add more columns the above one is just an example schema.
Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the students in the Student
details table. Every time the students changed their details like mobile number, 
You need to update their details in the student details table.  
Here is one thing you should ensure whenever the new students' details come , 
you should also store them in the Student backup table so that if you modify the details in the student details table, 
you will be having the old details safely.
You need not insert the records separately into both tables rather Create a trigger in such a way that It should insert the details into the Student
back table when you inserted the student details into the student table automatically. */

create table student_details (student_id int,
student_name varchar(30),
mail_id varchar(50),
mobile_no int);

create table student_details_backup (student_id int,
student_name varchar(30),
mail_id varchar(50),
mobile_no int);

delimiter //
create trigger insert_backup after insert 
on student_details for each row
begin 
insert into student_details_backup values (new.student_id,new.student_name,new.mail_id,new.mobile_no);
end//
delimiter ;

insert into student_details values (1,'Bala','bala@gmail.com',null);
insert into student_details values (2,'Chandru','lm10@gmail.com',123);

