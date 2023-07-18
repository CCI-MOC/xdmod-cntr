set global sql_mode='';
set global autocommit=1;
flush privileges;
create user xdmod@localhost identified by 'password';
UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
flush privileges;