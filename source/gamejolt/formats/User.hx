package gamejolt.formats;

/**
 * The way the user data is fetched from the GameJolt API.
 * 
 * @param id The ID of the User.
 * @param type The cathegory the User is cataloged like in GameJolt.
 * @param username The username of the User.
 * @param avatar_url The link of the avatar of the User.
 * @param signed_up A short description about how long the User have been in GameJolt.
 * @param signed_up_timestamp A long time stamp (in seconds) of when the User signed up.
 * @param last_logged_in A short description about the last time the User was found active in GameJolt.
 * @param last_logged_in_timestamp A long time stamp (in seconds) of the last time the User logged in GameJolt.
 * @param status The actual status of the User.
 * @param developer_name The display name of the User.
 * @param developer_website The website of the User.
 * @param developer_description The description of the User.
 */
typedef User =
{
    id:Int,
    type:String,
    username:String,
    avatar_url:String,
    signed_up:String,
    signed_up_timestamp:Int,
    last_logged_in:String,
    last_logged_in_timestamp:Int,
    status:String,
    developer_name:String,
    developer_website:String,
    developer_description:String
}