Facter.add(:monit_version) do
  setcode do
    if Facter::Util::Resolution.which('monit')
      Facter::Util::Resolution.exec("monit -V | head -1 | awk '{ print $5 }'")
    end
  end                                      
end                                        
