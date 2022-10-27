package gamejolt.formats;

/**
 * The way the trophies are fetched from your game API.
 * 
 * @param id The ID of the Trophie.
 * @param title The title of the Trophie.
 * @param description The description of the Trophie.
 * @param difficulty The difficulty rank of the Trophie.
 * @param image_url The link of the image that represents the Trophie.
 * @param achieved Whether this Trophie was achieved or not, it can be a string (with info about how much time ago it was achieved) or bool (false).
 */
typedef Trophie =
{
    id:Int,
    title:String,
    description:String,
    difficulty:String,
    image_url:String,
    achieved:Dynamic
}