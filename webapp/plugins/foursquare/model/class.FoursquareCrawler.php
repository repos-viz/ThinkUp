<?php
/**
 *
 * webapp/plugins/foursquare/model/class.FoursquareCrawler.php
 *
 * LICENSE:
 *
 * This file is part of ThinkUp (http://thinkupapp.com).
 *
 * ThinkUp is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any
 * later version.
 *
 * ThinkUp is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with ThinkUp.  If not, see
 * <http://www.gnu.org/licenses/>.
 * 
 *
 * Foursquare Crawler
 *
 * Retrives data from foursquare
 *
 * Copyright (c) 2011 Aaron Kalair
 * 
 * @author Aaron Kalair <aaronkalair[at]gmail[dot][com]
 * @license http://www.gnu.org/licenses/gpl.html
 * @copyright 2011 Aaron Kalair
 */

class FoursquareCrawler {
    /**
     *
     * @var Instance
     */
    var $instance;
    /**
     *
     * @var Logger
     */
    var $logger;
    /**
     * @var str
     */
    var $access_token;
    /**
     *
     * @var FoursquareAPIAccessor
     */
    var $api_accessor;
    
    /**
     *
     * @param Instance $instance - 
     * @param str $access_token - OAuth token so we can make API requests
     * @return FoursquareCrawler
     */
    public function __construct($instance, $access_token) {
        // set the global instance variable to the instance passed in
        $this->instance = $instance;
        // Create a new logger
        $this->logger = Logger::getInstance();
        // set the global access variable to the token passed in
        $this->access_token = $access_token;
        // Create a new API accessor
        $this->api_accessor = new FoursquareAPIAccessor();
    }
    
	/**
     * If user doesn't exist in the datastore, fetch details from the foursquare API and insert into the datastore.
     * If $reload_from_foursquare is true, update existing user details in store with data from foursquare API.
     * @param int $user_id foursquare user ID
     * @param str $found_in Where the user was found 
     * @param bool $reload_from_foursquare Defaults to false; if true will query foursquare API and update existing user
     * @return User 
     */
    public function fetchUser($user_id, $found_in, $force_reload_from_foursquare=false) {
        // Set the network to foursquare
        $network = 'foursquare';
        // Get a new user DAO
        $user_dao = DAOFactory::getDAO('UserDAO');
        // Set the user object to null, because ??
        $user_object = null;
        // If we need to refresh a users details or they are not already in the database
        if ($force_reload_from_foursquare || !$user_dao->isUserInDB($user_id, $network)) {
            // Get owner user details and save them to DB
    
            // Query the API for the users details
            $user_details =  $this->api_accessor->apiRequest('', $this->access_token);
            
        /* Set the network to foursquare so when we create our user object we know which network the details  
         * correspond to 
         */ 
        $user_details->network = $network;

        // Convert the JSON returned from the API into a ThinkUp user object
        $user = $this->parseUserDetails($user_details);
        
        // If the previous attempt to parse the users details succeed 
        if (isset($user)) {
            // Create a new user object with the details from foursquare
            $user_object = new User($user, $found_in);
            // Update the details in the database
            $user_dao->updateUser($user_object);
        }
        if (isset($user_object)) {
            // If the user object was sucessfully created log a success message
            $this->logger->logSuccess("Successfully fetched ".$user_id. " ".$network."'s details from foursquare",
            __METHOD__.','.__LINE__);
        } else {
            // If something went wrong report it
            $this->logger->logInfo("Error fetching "."5"." ". $network."'s details from the foursquare API, ".
            "response was ".Utils::varDumpToString($user_details), __METHOD__.','.__LINE__);
        }
        }
        // Return the User object
        return $user_object;
    }
    
    /**
     * Check the validity of foursquares OAuth token by requesting the instance user's details.
     * Fetch details from foursquares API for the current instance user and insert into the datastore.
     * @param str $access_token
     * @param str $owner_id
     * @return User
     */
    public function initializeInstanceUser($access_token, $owner_id) {
        // Set the network to foursquare
        $network = 'foursquare';
        // Get a new UserDAO
        $user_dao = DAOFactory::getDAO('UserDAO');
        // Set the user object to null as we need to run an isset() on it later to check our code updates it
        $user_object = null;
        
        // Query the API for the users details
        $user_details =  $this->api_accessor->apiRequest('', $this->access_token);
                      
        /* Set the network to foursquare so when we create our user object we know which network the details  
         * correspond to 
         */ 
        $user_details->network = $network;
         
        // Put the JSON details we got back from foursquare into an array
        $user = $this->parseUserDetails($user_details);
        
        // If this attempt succeed
        if (isset($user)) {
            // Create a new user Object with these details
            $user_object = new User($user, 'Owner initialization');
            // Insert them into the database
            $user_dao->updateUser($user_object);
        } 
        if (isset($user_object)) {
            // If the attempt to create a user object succeed put a note in the log
            $this->logger->logSuccess("Successfully fetched ".$user_object->username. " ".$user_object->network.
            "'s details from foursquare", __METHOD__.','.__LINE__);
        } else {
            // If something went wrong note this in the log
            $this->logger->logInfo("Error fetching ".$owner_id." ". $network."'s details from the foursquare API, ".
                "response was ".Utils::varDumpToString($user_details), __METHOD__.','.__LINE__);
        }
        // Return the user object
        return $user_object;
    }
    
    
 	/**
     * Retrieve OAuth tokens from foursquare as per:
     * https://developer.foursquare.com/overview/auth
     * @param str $client_id - The client ID the user provided
     * @param str $client_secret - The client secret the user provided
     * @param str $redirect_uri - The URL to redirect the user back to
     * @param str $code - A code foursquare provides so we can retrive the users OAuth token
     * @return Object with access_token 
     */
    public function getOAuthTokens($client_id, $client_secret, $redirect_uri, $code) {
        
        // Basic URL for getting the OAuth tokens
        $access_token_request_url = "https://foursquare.com/oauth2/access_token";
        
        // Create an array of field values
        $fields = array(
            'client_id'=>urlencode($client_id),
            'client_secret'=>urlencode($client_secret),
            'grant_type'=>urlencode('authorization_code'),
            'redirect_uri'=>urldecode($redirect_uri),
            'code'=>urlencode($code)
        );
                
        // Make a request for the OAuth tokens
        $tokens =  $this->api_accessor->rawPostApiRequest($access_token_request_url, $fields, true);

        // Return these tokens
        return $tokens;
    }
    
	/**
     * Convert decoded JSON data from foursquare into a ThinkUp user object.
     * @param array $details
     * @retun array $user_vals
     */
    private function parseUserDetails($details) {
        // We need atleast a name and ID to create a user object
        if (isset($details->response->user->contact->email) && isset($details->response->user->id)) {
            // Create an array to store our values in
            $user_vals = array();
            // Set the values in the array based on the data returned from the foursquare API
            $user_vals["user_name"] = $details->response->user->contact->email;
            $user_vals["full_name"] = $details->response->user->firstName." ".$details->response->user->lastName;
            $user_vals["user_id"] = $details->response->user->id;
            $user_vals["avatar"] = $details->response->user->photo;
            $user_vals['url'] = 'http://www.foursquare.com/user/'.$details->response->user->id;
            $user_vals["follower_count"] = null;
            $user_vals["location"] = $details->response->user->homeCity;
            $user_vals["is_protected"] = 0; 
            $user_vals["post_count"] = null;
            $user_vals["joined"] = null;
            $user_vals["network"] = $details->network;
            $user_vals["updated_time"] = 0;
            $user_vals["description"] = 'foursquare user';
            $user_vals["friend_count"] = $details->response->user->friends->count;
            return $user_vals;
        }
    }
    
    public function fetchInstanceUserCheckins(){
        // Make a query out to the API for this users checkins
        $checkins = $this->api_accessor->apiRequest('/checkins', $this->access_token);

        // Make a query out to the API for this users details, like name etc.
        $user =  $this->api_accessor->apiRequest('', $this->access_token);
        
        // Get a new Post DAO so we can store the users checkins
        $post_dao = DAOFactory::getDAO('PostDAO');
        
        // Get a new place DAO for storing the details about the place
        $place_dao = DAOFactory::getDAO('PlaceDAO');
        
        // Get a new Link DAO for storing any photos 
        $link_dao = DAOFactory::getDAO('LinkDAO');
        
        // For each checkin store it in the database
        foreach ($checkins->response->checkins->items as $item) {
            // The post ID, is the checkin ID foursquare provides
            $post['post_id'] = $item->id;
            // The post text is the text they enter when checking in
            $post['post_text'] =  isset($item->shout) ? $item->shout : " " ;
            // The author username is the users foursquare email address
            $post['author_username'] = $user->response->user->contact->email;
            // The author full name is the name they gave foursquare
            $post['author_fullname'] = $user->response->user->firstName." ".$user->response->user->lastName;
            // The avatar is the one they have set on foursquare
            $post['author_avatar'] = $user->response->user->photo;
            // The author user id is there foursquare user ID 
            $post['author_user_id'] = $user->response->user->id;
            // The date they checked in
            $post['pub_date'] = date( 'Y-m-d H:i:s' , $item->createdAt);
            // Not sure?
            $post['source'] = '';
            // Check if the checkin was marked as private
            if(isset($item->private)) {
                $post['is_protected'] = true;
            }
            else {
                $post['is_protected'] = false;
            }
            // Set the network to foursquare
            $post['network'] = 'foursquare';
            // Set place to the name of the place their checking into
            $post['place'] = $item->venue->name;
            // There are a few parameters that may or may not be set for location so let the method figure it out
            $post['location'] = $this->getLocation($item);
            //$post['location'] = $item->location->postalCode;
            // Place ID is an ID foursquare provides
            $post['place_id'] = $item->venue->id;
            // Set geo to the lat,lng that foursquare provides
            $post['geo'] = $item->venue->location->lat.",".$item->venue->location->lng;
            // These parameters cant be null but we don't need them for our plugin so set them to any empty string
            $post['reply_count_cache'] = '';
            $post['favlike_count_cache'] = '';
            $post['retweet_count_cache'] = '';
            $post['author_follower_count'] = '';
            
            // Store the checkin details in the database
            $done = $post_dao->addPost($post);
            
            // Check if any photos are attached to this checkin
            if($item->photos->count > 0 && $done != null) {
                foreach($item->photos->items as $photo) {
                    $photo_store = new Link(array(
                    'url'=> $photo->url,
                    'expanded_url'=> $photo->url,
                    'title'=> 'Checkin Photo',
                    'description'=> 'Checkin Photo',
                    'image_src'=> $photo->url,
                    'caption'=> 'Checkin Photo',
                    'clicks'=> 0,
                    'post_key'=> $done,
                    'error'=> 'none'));
                    
                    // Insert the photo into the database
                    $link_dao->insert($photo_store);
                    // Delete the current photo info ready for the next one
                    $photo_store = null;
                }
                                
            }
            
            // If there are any comments on this checkin capture them
            if($item->comments->count > 0) {
                
                // Make a query out for the comments
                $comments = $this->api_accessor->apiRequestBaseURL('/checkins/'.$item->id, $this->access_token);

                foreach ($comments->response->checkin->comments->items as $comment) {
                    // The post ID, is the comment ID foursquare provides
                    $comment_store['post_id'] = $comment->id;
                    // The post text is the comment they made 
                    $comment_store['post_text'] = $comment->text;
                    // The author username is the users foursquare email address (which we need to query for)
                    $username =  $this->api_accessor->apiRequestBaseURL('/users/'.$comment->user->id, $this->access_token);
                    $comment_store['author_username'] = $username->response->user->contact->email;
                    // The author full name is the name they gave foursquare
                    $comment_store['author_fullname'] = $comment->user->firstName." ".$comment->user->lastName;
                    // The avatar is the one they have set on foursquare
                    $comment_store['author_avatar'] = $comment->user->photo;
                    // The author user id is there foursquare user ID 
                    $comment_store['author_user_id'] = $comment->user->id;
                    // The date they posted the comment
                    $comment_store['pub_date'] = date( 'Y-m-d H:i:s' , $comment->createdAt);
                    // Not sure?
                    $comment_store['source'] = '';
                    // Comments can not be private 
                    $comment_store['is_protected'] = false;
                    // Set the network to foursquare
                    $comment_store['network'] = 'foursquare';
                    // Set place to the name of the place the comment is about
                    $comment_store['place'] = $comments->response->checkin->venue->name;
                    // There are a few parameters that may or may not be set for location so let the method do the work
                    $comment_store['location'] = $this->getLocation($item);
                    // Place ID is an ID foursquare provides
                    $comment_store['place_id'] = $comments->response->checkin->venue->id;
                    // Set geo to the lat,lng that foursquare provides
                    $comment_store['geo'] = $item->venue->location->lat.",".$item->venue->location->lng;
                    // The ID of the author of the checkin
                    $comment_store['in_reply_to_user_id'] = $user->response->user->id;
                    // The ID of the checkin this is a reply to
                    $comment_store['in_reply_to_post_id'] = $item->id ;
                    // The number of replies this checkin has
                    $comment_store['reply_count_cache'] = $item->comments->count;
                    // These parameters cant be null but we don't need them so set them to any empty string
                    $comment_store['reply_count_cache'] = '';
                    $comment_store['favlike_count_cache'] = '';
                    $comment_store['retweet_count_cache'] = '';
                    $comment_store['author_follower_count'] = '';  

                     // Now store the comment in the database
                     $post_dao->addPost($comment_store);
                     
                     $comment = null;
                     
                 }
            }
            
                        
            // Store the details about this place in the place table if it doesn't already exist
            
            // See if this place is already in the database
            $place_test = $place_dao->getPlaceByID($item->venue->id);
            
            // If it isn't already in the database
            if($place_test == null) {
                // Insert it
                $places['id'] = $item->venue->id;
                $places['place_type'] = $item->venue->categories[0]->name;
                $places['name'] = $item->venue->name;
                $places['full_name'] = $item->venue->name;
                $places['icon'] = $item->venue->categories[0]->icon; 
                $places['lat_lng'] = 'POINT('.$item->venue->location->lat." ".$item->venue->location->lng.')';
                $places['map_image'] = $this->generateMap($item);
                $place_dao->insertGenericPlace($places, 'foursquare');
            }
            
            // Blank out the details ready for the next checkin
            $post = null;
            $places = null;
        }
   
    }
       
    /* Parse a checkin on foursquare to determine how many details about the location were set
     * @param array checkin data
     * @return String containing as many details about the checkin location as possible
     */
    private function getLocation($details){
        $location = '';

        if(isset($details->venue->location->city))
        {
            $location = $location.$details->venue->location->city;
            
            if(isset($details->venue->location->postalCode)) {
                 $location = $location.", ".$details->venue->location->postalCode;
            }
        }
        else
        {
            
            $location = $details->venue->location->postalCode;
        }
        
        return $location;
    }
    
    /* Generate the URL to get a google map with a marker at the checkin location
     * @param array $details - Decoded JSON from foursquare
     * @return string - Google maps URL
     */
    private function generateMap($details){
        $url = 'http://maps.googleapis.com/maps/api/staticmap?size=150x150&zoom=15&maptype=roadmap&markers=';
        $url = $url.'color:blue%7C'.$details->venue->location->lat.','.$details->venue->location->lng.'&sensor=false';
       
        return $url;
    }
    
}
