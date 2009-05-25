# yUMLmeRails

This is a simple plugin that adds Rake tasks to display model diagrams for RoR apps.

It uses an extended RailRoad to output yUML diagrams which are drawn using the service at [yUML](http://yuml.me)

There's also a small Shoes app to display the downloaded diagram.

## Example

<img src="http://yuml.me/diagram/scruffy/class/[User],[Task],[Assignment],[Status],[User]1-*[Assignment],[Task]1-*[Assignment],[Task]1-*[Status]"/>

## Requirements

 * Shoes
 * wget (I'm using it to dowload the image for now since openuri wasn't found of my URI)
    
## Instalation

 * Just clone this into vendor/plugins
    
## Usage (rake -T)
  
 * rake yUMLmeRails:download            # Download yUML model diagram
 * rake yUMLmeRails:show                # Show model diagram
 * rake yUMLmeRails:url                 # Get yUML URL
    
Feel free to do whatever you want with the code but please share your results with us.
