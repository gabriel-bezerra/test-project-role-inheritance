#!/usr/bin/env bash
set -e

KEYSTONE_HOST=${KEYSTONE_HOST:-localhost}

source keystone.sh

TOKEN_ADMIN=$(get_project_scoped_token "Default" "admin" "admin" "Default" "demo")

echo Deleting domains: Domain-A
delete_domain $TOKEN_ADMIN $(domainid_from_name $TOKEN_ADMIN "Domain-A")

# Fixture
echo Creating domains: Domain-A
DOMAIN_A_ID=$(create_domain $TOKEN_ADMIN "Domain-A")

echo Creating Project-A
PROJECT_A_ID=$(create_project $TOKEN_ADMIN $DOMAIN_A_ID "Project-A")
echo Creating SubProject-A
SUBPROJECT_A_ID=$(create_subproject $TOKEN_ADMIN $DOMAIN_A_ID "SubProject-A" $PROJECT_A_ID)

echo Creating User-A
USER_A_ID=$(create_user $TOKEN_ADMIN $DOMAIN_A_ID "User-A" "User-A-password")

MEMBER_ROLE_ID=$(roleid_from_name $TOKEN_ADMIN "Member")
echo Assigning Member role to User-A in Project-A
add_inherited_project_role $TOKEN_ADMIN $PROJECT_A_ID $USER_A_ID $MEMBER_ROLE_ID
#echo Assigning Member role to User-A in Domain-A
#add_inherited_domain_role $TOKEN_ADMIN $DOMAIN_A_ID $USER_A_ID $MEMBER_ROLE_ID


echo Listing inherited roles on Project-A
#curl -X GET -H "X-Auth-Token: $TOKEN_ADMIN" "http://$KEYSTONE_HOST:5000/v3/OS-INHERIT/projects/$PROJECT_ID/users/$USER_ID/roles/$ROLE_ID/inherited_to_projects"
curl -X GET -H "X-Auth-Token: $TOKEN_ADMIN" "http://$KEYSTONE_HOST:5000/v3/OS-INHERIT/projects/$PROJECT_A_ID/users/$USER_A_ID/roles/inherited_to_projects" | ./jq .

echo Listing inherited roles on SubProject-A
curl -X GET -H "X-Auth-Token: $TOKEN_ADMIN" "http://$KEYSTONE_HOST:5000/v3/OS-INHERIT/projects/$SUBPROJECT_A_ID/users/$USER_A_ID/roles/inherited_to_projects" | ./jq .

echo Listing role grants on SubProject-A
curl -X GET -H "X-Auth-Token: $TOKEN_ADMIN" "http://$KEYSTONE_HOST:5000/v3/projects/$SUBPROJECT_A_ID/users/$USER_A_ID/roles" | ./jq .

echo Listing role assignments
curl -X GET -H "X-Auth-Token: $TOKEN_ADMIN" "http://$KEYSTONE_HOST:5000/v3/role_assignments?user.id=$USER_A_ID" | ./jq .

echo Listing effective role assignments
curl -X GET -H "X-Auth-Token: $TOKEN_ADMIN" "http://$KEYSTONE_HOST:5000/v3/role_assignments?effective&user.id=$USER_A_ID" | ./jq .

echo Project-A id = $PROJECT_A_ID
echo SubProject-A id = $SUBPROJECT_A_ID

# Clean up
echo Deleting SubProject-A
delete_project $TOKEN_ADMIN $SUBPROJECT_A_ID
echo Deleting Project-A
delete_project $TOKEN_ADMIN $PROJECT_A_ID

echo Deleting domains: Domain-A
delete_domain $TOKEN_ADMIN $DOMAIN_A_ID
