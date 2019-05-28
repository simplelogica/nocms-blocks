##
# This is the Base serializer that will do whatever is necessary to store the
# value of a field in a container.
#
# This Base serializer delegates the read/write operations in its subclasses
# that should implement the desired behaviours. It also implements the duplicate
# method that duplicates the field according to the configuration.
class NoCms::Blocks::BaseSerializer

  attr_accessor :container, :field, :field_config

  ##
  # We need the name of the field, its configuration and the container as we may
  # need any of them in order to retrieve/store the value
  def initialize field, field_config, container
    @field = field
    @field_config = field_config
    @container = container
  end

  ##
  # This method just delegates the reading to a subclass, but it may allow us to
  # customize some behaviour in the Base Serializer in the future
  def read
    read_field
  end

  ##
  # Method that must be overwritten by the subclass with the implementation for
  # reading the field's value
  def read_field
    raise NotImplementedError.new("The serializer #{self.inspect} has no 'read_field' implementation")
  end

  ##
  # This method delegates the writing to a subclass and marks the container as
  # changed, so ActiveRecord saves it. This prevents translations not being
  # saved in some Rails versions.
  def write value
    write_field value
    self.container.fields_info_will_change!
  end

  ##
  # Method that must be overwritten by the subclass with the implementation for
  # writing the field's value
  def write_field value
    raise NotImplementedError.new("The serializer #{self.inspect} has no 'write_field' implementation")
  end

  ##
  # Standard duplicate behaviour. It uses the read and write implementations to
  # read and write the new duplicated value.
  #
  # It takes into account that the field may be an AR object and updates
  # the cached objects.
  #
  # We have different options of duplication depending on the field's
  # configuration:
  #
  #  * duplication: It's the default behaviour. It just performs a dup
  #    of the field and expects the attached object to implement dup in
  #    a proper way.
  #
  #  * nullify: It doesn't dup the field, it empties it. It's useful for
  #    objects we don't want to duplicate, like images in S3 (it can
  #    raise a timeout exception when duplicating).
  #
  #  * link: It doesn't dup the field but stores the same object. It's
  #    useful in Active Record fields so we can store the same id and
  #    not creating a duplicate of the object (e.g. if we have a block
  #    with a related post we don't want the post to be duplicated)
  def duplicate

    field_value = read

    dupped_value = case field_config[:duplicate]
      # When dupping we just dup the object and expect it has the right
      # behaviour. If it's nil we save nil (you can't dup NilClass)
      when :dup
        field_value.nil? ? nil : field_value.dup
      # When nullifying we return nil
      when :nullify
        nil
      # when linking we return the same object
      when :link
        field_value
    end

    write dupped_value

  end

end
