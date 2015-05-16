Puppet::Type.newtype(:runlevel) do

  @doc = "Changes the system runlevel by re-evaluating the inittab or systemd link.
    Arguments:

    name
      - the runlevel to evaluate for the system

    persist
      - boolean value that determines whether or not to set as the default runlevel of the system

    Example:

        runlevel { '3': persist => true, }
  "

  def initialize(*args)
    super(*args)

    found_resource = nil

    if not catalog.resources.find_all { |r|
      r.is_a?(Puppet::Type.type(:runlevel)) and found_resource = r
    }.empty? then

      msg = "Duplicate declaration: Runlevel is already declared in file #{found_resource.file} at line #{found_resource.line}. Can not declare more than one instance of Runlevel."

      raise Puppet::Resource::Catalog::DuplicateResourceError.new(msg)
    end
  end

  newparam(:name, :namevar => true) do
    desc 'The target runlevel of the system'
    newvalues(/^[1-5]$/, 'rescue', 'multi-user', 'graphical')

    munge do |value|
      case value
        when 'rescue' then '1'
        when 'multi-user' then '3'
        when 'graphical' then '5'
        else value
      end
    end
  end

  newproperty(:persist) do
    desc 'Whether or not to save the runlevel as default.'
    newvalues(:true, :false)
    defaultto :true
  end
end
