#if defined _user_find_or_create_rep_response_included
    #endinput
#endif
#define _user_find_or_create_rep_response_included

// kind of useless since i only need ids.
enum E_USER_FIND_OR_CREATE_REP_RESPONSE {
    u_ID,
    u_Username[MAX_PLAYER_NAME] 
};