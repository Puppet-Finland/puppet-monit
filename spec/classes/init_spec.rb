require 'spec_helper'

describe 'monit' do

  let(:title) { 'monit' }
  let(:node) { 'test.example.org' }
  let(:facts) { {
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
    :lsbdistcodename => 'bionic',
    :servermonitor   => 'root@localhost',
  } }

  it { is_expected.to compile.with_all_deps }
end
