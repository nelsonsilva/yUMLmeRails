Fork from [dmitry](http://github.com/dmitry/yUMLmeRails/) < [nelsonsilva](http://github.com/nelsonsilva/yUMLmeRails/) to adapt/improve some things (according to my working style).

# yUMLmeRails

This is a simple plugin that adds Rake tasks to display model diagrams for RoR apps.

It uses an extended RailRoad to output yUML diagrams which are drawn using the service at [yUML](http://yuml.me)

## Example

<img src="http://yuml.me/diagram/scruffy/class/[User],[Task],[Assignment],[Status],[User]1-*[Assignment],[Task]1-*[Assignment],[Task]1-*[Status]"/>

## Installation

* Add to your Gemfile:
  `gem 'yUMLmeRails', :git => 'git://github.com/tute/yUMLmeRails.git'`

## Usage (rake -T)

 * rake yUMLmeRails:download            # Download yUML model diagram to doc/diagrams
 * rake yUMLmeRails:show                # Show model diagram
 * rake yUMLmeRails:url                 # Get yUML URL

Feel free to do whatever you want with the code but please share your results with us.
