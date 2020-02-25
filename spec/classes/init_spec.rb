# frozen_string_literal: true

require 'spec_helper'

describe 'monit' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      extra_facts = if os_facts[:osfamily] == 'RedHat'
                      { servermonitor: 'root@localhost', lsbdistcodename: 'RedHat' }
                    else
                      { servermonitor: 'root@localhost' }
                    end

      let(:facts) { os_facts.merge(extra_facts) }

      it { is_expected.to compile }
    end
  end
end
