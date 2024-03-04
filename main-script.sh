#!/bin/bash
# Display the menu options
function display {

	echo "Please enter your choice : "
	echo "option 1  --> check user is present or not"
	echo "option 2  --> create a new user"
	echo "option 3  --> remove existing user"
	echo "option 4  --> change password of a user :modifying existing user"
	echo "option 5  --> rename login username" 
	echo "option 6  --> list all new custom users"
	echo "option 7  --> check a particular group is exist or not"
	echo "option 8  --> list and count all users present in a group"
	echo "option 9  --> create a new group"
	echo "option 10  --> add user into a group"
	echo "option 11 --> delete user from a group"
	echo "option 12 --> remove a group"
	echo "option 13 --> list all groups"
	echo "option 14 --> check user's groups name"
	echo "option 15 --> take backup"

}

function user_present {
      
	read -p "Enter user name : " userName
	
	if id "$userName" &>/dev/null; then

		echo "yes, user is present"

	else
		echo "no, user is not present"
	fi

}

function create_user {

	# if user is already exited or not
	read -p "Enter the user name: " username
	
	if id "$username" &>/dev/null; then
		# user already present
		echo "Sorry, user "$username" is already present, pls use different user name"
        
        else
		# create user
		read -p "Enter password: " password
		sudo useradd -m -p "$password" "$username"
		echo "user $username is successfully created"

	fi
 
}	


function remove_user {

	# check user is already there
        read -p "Enter user name to delete: " username

	if id "$username" &>/dev/null; then
		# user is already present,so remove it
		sudo userdel -r "$username"
		echo "user $username is deleted sucessfully"

	else
		# user is not already present
		echo "user $username is not exit, please enter a valid user name"

	fi

}


function change_password {

	read -p "Enter username : " username

	# check user present or not
	if id "$username" &>/dev/null; then
		# user is exited
		#read -p "Enter your password" password
		sudo passwd $username

	else
	       echo "sorry,user $username is not existed,enter a valid username"


        fi	       
 		
}

function rename_login_username {

        # Rename the user and the home directory
	read -p "Enter user name to rename : " old_username

	if id "$old_username" &>/dev/null; then

                read -p "Enter new user name : " new_username
                sudo usermod -l "$new_username" -d "/home/$new_username" -m "$old_username"
		echo "username of $new_username is sucessfully updated"

        else
		echo "sorry user $old_username is not exist,enter a valid user name"

	fi

}

function listall_customusers {

	# list all new custom users

	#list all users with username and UID
	#awk -F : 'NR > 35 {print NR,$1 "--->" "(UID:"$3")"}' /etc/passwd

	# list all usernames with password
	#sudo awk -F : 'NR > 35 {print NR,$1,$2}' /etc/shadow
	sudo awk -F : 'NR > 35 {print NR,"username : "$1,"   password : "$2}' /etc/shadow
	
	# list all username with uid
	#cat /etc/passwd | awk -F : 'NR > 35 {print"-" NR,$1 "(UID : "$3")"}'


}

function check_group {

	read -p "Enter a group name : " groupname

	# check a group is present or not
	if getent group $groupname &>/dev/null; then

		echo "group '$groupname' is existed"

	else
		echo "sorry, group $groupname is not existed, enter a valid group name"

	fi

}

function list_all_groups {

	#list all groups including primary & secondary groups
	#command: cat /etc/group
	echo "list of all groups including primary & secondary groups are : "
	sudo awk -F : 'NR > 60 {print NR,$1,$2,$3,$4}' /etc/group
}


function users_in_a_group {
	#list all users in a group
	#command : getent group "$groupname" | awk -F ":" '{print $4}'
	read -p "Enter a valid group name : " groupname
	#check group is exist or not
	if getent group $groupname &>/dev/null; then
		#group is existed
		#command to filter all users in a group
		users=$(getent group "$groupname" | awk -F ":" '{print $4}'| tr ',' '\n')
		echo "users in group '$groupname'are : "
                #list all user via loop
		count=0
		for user in $users
		do
			echo $user
			((count++))
	

		done

		echo "total number of users in this group are : $count"

	else 
		#group is not existed
		echo "group '$groupname' is not existed, please enter a valid group name"

	fi

}

function create_group {
	
	read -p "Enter group name : " groupname

	if getent group $groupname &>/dev/null; then
		# group is exised
		echo "group $groupname is already exist"

	else
		# create a new group
		sudo groupadd $groupname
		echo "group '$groupname' is successfully created"

	fi

}

function add_users_into_group {

	read -p "Enter group name : " groupname
	
	if getent group $group &>/dev/null; then
		#group is alrady existed
		#add user into a group
		read -p "Enter username to add into $groupname : " username
		if id "$username" &>/dev/null; then
			#user is already existed
			#sudo gpasswd -a <username> <groupname>
			sudo usermod -aG $groupname $username
			echo "user '$username' is successfully added into group '$groupname'"

		else
			echo "user $username is not existed, go and first create user from 'option 2'"

		fi

	else 
		echo "group $groupname is not existed, go and first create a new group from 'option 9'"

	fi 

}

function remove_user_from_group {

	read -p "Enter group name : " groupname

	#check group is existed or not

	if getent group $groupname &>/dev/null; then
		#group is exist
		read -p "enter user name to remove from group $groupname : " username

		#check user ia existed or not overall
		if id "$username" &>/dev/null; then
			#user is existed overall
			#check user is existed in a group or not , use: "groups command"
		        if groups "$username" | grep -q "\b$groupname\b"; then
				#user is exist in this group
				sudo gpasswd -d $username $groupname
				echo "user '$username' is deleted successfully from group '$groupname'"

			else 
				#user is not exist in this group
				echo "user '$username' is not a part of this group '$groupname',enter a valid user name "
			fi
		else 
		       #user is not existed overall
		       echo "user '$username' is not existed in the whole system, please enter a valid user name" 
		       
		fi

	else 
		#group is not exist
		echo "group '$groupname' is not existed,enter a valid group name"

	fi

}

function delete_group {

	read -p "Enter a valid groupname : " groupname
	#check group is exist or not
	if getent group $groupname &>/dev/null; then
		#group is exist
		sudo groupdel $groupname
		echo "group '$groupname' is successfully deleted"

	else 
		#group is not exist
		echo "group '$groupname'is not existed,enter a valid group name"

	fi

}

function check_user_groupname {

	read -p "Enter a valid user name : " username
	#check user is exist or not
	if id "$username" &>/dev/null; then
		#user is exist
		grep -i $username /etc/group

	else 
		#user is not exist
		echo "user '$username' is not existed, please enter a valid user name"

	fi

}

function take_backup {

       
        #take src path input
	read -p "Enter the path for src folder : " src_dir

	#take dest path input
	read -p "Enter the path for tgt folder : " tgt_dir

	#make a backup file name
	backup_filename="backups_$(date +%Y-%m-%d-%H-%M-%S).tar.gz"

	echo "Backup begins"

	#tar -czvf <dest> <src>
	tar -czvf "${tgt_dir}/${backup_filename}" "$src_dir"

	echo "Backup completed"


}


while [ "$#" -gt 0 ] 
do
	display
	read -p "Enter your option : " option

case $option in
	1)
		user_present
		exit
		;;

	2) 
		create_user
		exit
		;;

        3)
		remove_user
		exit
		;;

	4)
		change_password
		exit
		;;

	5)
		rename_login_username
		exit
		;;

	6) 
		listall_customusers
		exit
		;;

	7)
		check_group
		exit
		;;

	8)
		users_in_a_group
		exit
		;;

	9)
		create_group
		exit
		;;

	10)
		add_users_into_group
		exit
		;;

	11) 
		remove_user_from_group
		exit
		;;

	12) 
		delete_group
		exit
		;;

	13) 
		list_all_groups
		exit
		;;

	14) 
		check_user_groupname
		exit
		;;

	15) 
		take_backup
		exit
		;;

	*)
		echo "wrong command"
		echo "please enter only  a number from 1 to 15"
		exit
		;;


esac

done



