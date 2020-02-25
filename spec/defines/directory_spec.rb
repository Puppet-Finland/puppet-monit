# frozen_string_literal: true

require 'spec_helper'

describe 'monit::directory' do
  let(:title) { 'boot-fs' }
  let(:params) { { 'path' => '/boot', 'threshold' => 300 } }
  let(:pre_condition) { 'include ::monit' }

  bionic = { supported_os: [{ 'operatingsystem'        => 'Ubuntu',
                              'operatingsystemrelease' => ['18.04'] }] }

  on_supported_os(bionic).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge(servermonitor: 'root@localhost') }

      it { is_expected.to compile }
    end
  end
end
