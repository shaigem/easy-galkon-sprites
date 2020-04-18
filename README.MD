# Easy Galkon Sprites (EGS)

Easy Galkon Sprites (EGS) contains a collection of tools that assists in decoding and encoding cache files (sprites.dat and sprites.idx) that uses Galkon's sprite cache format.

## Tools

### unpack

This tool unpacks images and their metadata from the cache (sprites.dat and sprites.idx) into a workspace folder.
This allows the user to edit sprites using tools already provided by the OS (eg. Windows Explorer and Notepad on Windows)

### pack

This tool creates a new cache (sprites.dat and sprites.idx) from the workspace folder and outputs the new cache.

### bulkimport

This tool imports images from a folder containing PNG images in the working folder. Images imported are appended to the end of the filesystem in the workspace folder.

## How does this work?

What Easy Galkon Sprites does is unpack all of the sprites from sprites.dat/idx into a workspace folder called "working". After unpacking, you can use your desired file manager (Windows Explorer for Windows, Thunar on Linux, etc.) to remove, replace and add sprites to your liking! You can also edit the sprite's metadata using your desired text editor. There is no need to use another UI application for managing your sprites.

After you are done editing your sprites, use the "pack" tool to pack your changes into a new cache

## Usage (Windows)

#### Setting up

1. Place your sprites.dat and sprites.idx into the "input" folder
2. Run "unpack.bat"

This dumps all of your images into the "working" folder. It also dumps the image's metadata such as name, offsetX, offsetY, etc. into a file called "metadata.yaml"

Here is what your "working" folder should look like:
![](https://i.imgur.com/JtE1bir.png)

#### Adding Sprites

Here are some warnings when adding sprites:

1. Sprites can only be added at the end! So if your highest sprite id is 1033, you can only add new sprites after that (1034, 1035, etc.)
2. After adding new sprites, MAKE SURE YOU EDIT the "metadata.yaml" file to reflect the change.
3. Sprites must be in PNG format

Here is an example of me adding a new sprite:

1. Go to your "sprites" folder in the "working" folder
2. Add your desired sprite and rename it appropriately

![](https://i.imgur.com/chCcfUI.png)

In the picture above, I added the shopping cart and named it "1034.png"

3. Go back to your "working" folder and add the new sprite to "metadata.yaml" using your favourite text editor (using VS Code here)

![](https://i.imgur.com/zNEhgRh.png)

Now I add the 1034.png to the metadata:

![](https://i.imgur.com/7HzLCdn.png)

#### Bulk Importing Multiple Sprites

What if you want to add a lot of sprites? Manually adding each sprite and renaming them to their appropriate ids will take a long time.
Solution: use the "bulkimport" tool!

Note this tool ignores all file names so you can add sprites from other caches very easily!

1. In the "working" folder, there is a "bulk-import" folder. Add your images in there:

"bulk-import" folder
![bulk-import folder](https://i.imgur.com/3S3turX.png)

2. Run "bulkimport.bat"

There you go! Now when I go back to my working/sprites/ folder, I see this:

![](https://i.imgur.com/wRj7h3O.png)

This tool also updates "metadata.yaml" for you.

Remember to delete the images in the "bulk-import" folder when you are done.

#### Deleting Sprites

Deleting sprites is pretty much the same process as adding sprites. Just remember these notes:

1. Sprites can only be deleted from the end! So if your highest sprite id is 1033, you have to delete from there! You can't delete 0.png, etc.
2. After deleting sprites, MAKE SURE YOU EDIT the "metadata.yaml" file to reflect the change.

#### Packing Sprites

Run "pack.bat" to create a new sprites.dat and sprites.idx cache in the "output-cache" folder. You can copy these files into your client's cache to replace them to update changes.

## License
[MIT](https://choosealicense.com/licenses/mit/)
