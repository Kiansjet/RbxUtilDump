--[[
	
	--- KIANSJET'S PASTEBIN API FOR ROBLOX DOCUMENTATION ---
	
	(Throughout this documentation, the word 'mod' will be used to reference the module after require()ment)
	Root table of functions upon require()ment:
	
	PROPERTIES:
		
		- mod.apiKey
		  An API key is made for every user on pastebin.com. Any logged in user can view
		  their key at ( pastebin.com/api#1 ). This variable is required to be set for any
		  of the module's functions to work.
		
		- mod.userKey
		  This key is required for some but not all of the module's functions to work. One
		  can be generated with mod.GetUserKeyAsync() or you can use pastebin's page for this:
		  ( https://pastebin.com/api/api_user_key.html ) Any functions that require this key to
		  be set will have the tag: [NEED USER KEY]
		  [NOTE]: If you signed up for pastebin using a service such as Google or Twitter, you may
		  need to use the change password page to make one before being able to generate a user key.
		
		- mod.bodyLengthCap
		  This integer is set to 524288 by default. Any string body longer than this integer will be halted from
		  being posted by mod.PasteAsync(). This is roughly half a megabyte. Roblox's http post data cap is 1MB at
		  the time of writing this documentation. Feel free to mess with this value.
		
	FUNCTIONS:
	
		[Note]: The following functions all follow the same return pattern, similar to a pcall().
		If the Success bool is true, then the Data string should contain the data you need. Otherwise,
		the Data bool will contain an error.
		[Note 2]: When attempting to fetch a paste with mod.GetPasteAsync() or mod.ApiGetPasteAsync(), the
		module will run the output through a 'filter' designed to catch any API errors that may have been
		returned, preventing you from thinking you successfully got a paste, but actually just got a pastebin
		API error. For this reason, if any pastes you fetch begin with the follwing strings:
		'Bad API request'
		'Error with this ID'
		then the filter will pick these up as API errors, and return false, followed by the error.
	
		- [ bool Success , string Data ] mod.GetUserKeyAsync( string Username , string Password )
		  This function returns a user key in the Data value that you can set as the mod.userKey in
		  order to use any functions that may require it.
		
		- [ bool Success , string Data ] mod.GetPasteAsync( string pasteId )
		  This function returns the raw paste data of any PUBLIC or UNLISTED paste with the provided
		  PasteId.
		
		- [ bool Success , string Data ] mod.ApiGetPasteAsync( string pasteId ) [NEED USER KEY]
		  This function is almost identical to mod.GetPasteAsync(), although this one requires a
		  mod.userKey and allows for the retrieval of PRIVATE pastes (as long as the user logged in
		  with their UserKey has access to the paste.)
		
		- [ bool Success , string Data ] mod.PasteAsync( string body , string name , string format , int privacy , string expiration )
		  This is obviously the main use function of the module, so it's expected to have a long documentation. This function
		  returns a url to the paste you have posted IF it passes the following tests:
		  
		  - The body string must be <= mod.bodyLengthCap in length
		  - The name string must be <= 50 characters in length (This is roughly pastebin's hard cap)
		  - The format string needs to be a blank string OR one of pastebin's supported languages: ( pastebin.com/api#5 )
		  - The privacy string needs to be an integer between 0 and 1 ( 0 = Public  | 1 = Unlisted )
		    [NOTE]: If a mod.userKey is defined, you can also set privacy to 2 for Private.
		  - The expiration string needs to be in pastebin's expiration context: ( pastebin.com/api#6 )
		
		  Only the body string is required. If the rest are left out, they will default to:
		  Name: 'Paste from: https://www.roblox.com/games/'..tostring(game.PlaceId)
		  Format: 'lua'
		  Privacy: 0
		  Expiration: 'N'
		
		  If you ever intend to delete a paste made with mod.PasteAsync(), then make sure to define
		  mod.userKey so you will have the permission to delete the paste moving on.
		
		- [ bool Success , string Data ] mod.DeletePasteAsync( string pasteId ) [NEED USER KEY]
		  This function deletes any paste (provided that the logged in user has the permission to)
		
	ERROR BREAKDOWN:
	
		This section is dedicated to listing possible errors and their origins.
		
		If a function ever returns false as it's status, the data string will almost always be an error.
		
		Errors in data validation (such as passing a string to the function when an integer is expected)
		will beign with this: 'Error in preprocessing:'
		
		If there is an error in the POST or GET, the module will assume the error is Roblox's fault, and
		the error will begin with 'Error during (POST/GET):' followed by the Roblox error provided by the pcall().
		
		If any API errors are caught (therefore on pastebin's side) (extended explanation in note 2 under FUNCTIONS),
		the error string will always begin with 'Bad API request:' followed by the API error.
		
		If an error is returned that begins with 'Error [Undocumented]:' then I have no idea what went wrong, but
		Roblox successfully performed the POST/GET, and returned nil.
	
]]
