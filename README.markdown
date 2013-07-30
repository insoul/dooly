Dooly
==========

_Dooly_ is a character of Korean animation. [둘리](http://ko.wikipedia.org/wiki/%EB%91%98%EB%A6%AC)

This gem offer an extension for Rails Serialization, and some helpful feature. 


Installation
============

    $ gem install dooly



Usage
==========


Attachment
----------

By including Dooly::Attachment in your class, that class can attach some data to the instance

```ruby
require 'dooly'

class User < ActiveRecord::Base
  include Dooly::Attachment
  make_attachable_as_json
end

user = User.first
user.attachment.add(:email, 'dooly@kogil.dong')
user.attachment.add(:friends) do |u|
  u.friends
end
user.attachment.add(:address, {:city=>'seoul'}) do |u, addr_hash|
  addr_hash.merge(:landlord=>'ko gil dong')
end

user.as_json
  # {
  #   'name'=>'dooly', ... ,
  #   'email'=>'dooly@kogil.dong',
  #   'friends'=>user.friends.as_json,
  #   'address'=>{'city'=>'seoul', 'landlord'=>'ko gil dong'}
  # }
```

Also extended attachment class can be apply

```ruby
class User < ActiveRecord::Base
  include Dooly::Attachment
  
  class Attachment < Dooly::Attachment::Base
    def add_email
      self[:email] = body.email
    end
  end
  
  make_attachable_as_json User::Attachment
end

user = User.first
user.attachment.add_email
user.as_json #=> {..., 'email'=>'dooly@kogil.dong'}
```


IdProxy
----------

IdProxy is a simple idea for class method that need only model id.

```ruby
class User < ActiveRecord::Base
  def self.friends(id)
    NoSQL.find_friends_of(id)
  end
  
  def friends
    self.class.friends(self.id)
  end
end
```

using IdProxy...

```ruby
class User < ActiveRecord::Base
  include Dooly::IdProxy
  
  class IdProxy < Dooly::IdProxy::Base
    def friends
      NoSQL.find_friends_of(id)
    end
  end
  
  id_proxy_class IdProxy
  id_proxy_delegate
  
  def another_instance_method
  end
end

User.id_proxy(1).friends
User.first.friends                       # instance of original class can call method of id_proxy
User.id_proxy(1).another_instance_method # id_proxy can call instance method of original class
```

Collection
----------

Fix as_json root option for collection classes. as-is,

```ruby
User.where('id < 10').as_json(:root=>'users')
  # [
  #   {"users"=>{"name"=>"dooly"}},
  #   {"users"=>{"name"=>"ddochi"}},
  #   ...
  # ]
```

fix this,

```ruby
Dooly::Collection::Base.new(User.where('id < 10')).as_json(:root=>'users')
  # {
  #   "users" => [
  #     {"name"=>"dooly"},
  #     {"name"=>"ddochi"}
  #   ]
  # }
```


Model Regulator
---------------

Model Regulator can reduce effort of parameter validation.

```ruby
class User < ActiveRecord::Base
  include Dooly::ModelRegulator
end

class Friend < ActiveRecord::Base
  # this methods can accept number id of user, 
  # number id's string of user, user instance, and id_proxy of user
  
  def self.sample_method(user)
    u = User.by(user)
    # u is a user instance
  end
  
  def self.example_method(user)
    uid = User.id(user)
    # uid is a number id of user
  end
end
```
