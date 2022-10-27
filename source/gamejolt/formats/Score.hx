package gamejolt.formats;

/**
 * The way the scores are fetched from your game API.
 * 
 * @param score The stringified Score.
 * @param sort The value of the Score.
 * @param extra_data Extra data about the Score.
 * @param user The username of the User who teached this Score (if it's a registered User).
 * @param user_id The ID of the User who reached this Score (if it's a registered User).
 * @param guest The "guest" name of the User who reached this Score (if it's NOT a registered User).
 * @param stored A short description about the date the User reached this Score.
 * @param stored_timestamp A long time stamp (in seconds) of the date the User reached this Score.
 */
typedef Score = 
{
    score:String,
    sort:Int,
    extra_data:String,
    ?user:String,
    ?user_id:Int,
    ?guest:String,
    ?stored:String,
    ?stored_timestamp:Int
}