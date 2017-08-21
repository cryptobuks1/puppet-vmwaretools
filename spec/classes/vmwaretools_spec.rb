require 'spec_helper'

default_facts = {
    :is_virtual => true,
    :kernel     => 'Linux',
    :virtual    => 'vmware',
    :os         => {
        'name'    => 'CentOS',
        'family'  => 'RedHat',
        'release' => {
            'major' => '7'
        }
    }
}

describe 'vmwaretools', :type => :class  do

  context 'default' do
    let (:facts) do default_facts.merge({ :vmwaretools_version => '9.2.0' })  end
    it { is_expected.to contain_class('vmwaretools::params') }
    it { is_expected.to contain_class('vmwaretools::config_tools') }
    it { is_expected.to contain_class('vmwaretools::install') }
  end

  context 'no vmwaretools_version' do
    let (:facts) do default_facts  end
    it { is_expected.to raise_error(Puppet::Error, /vmwaretools_version fact not present, please check your pluginsync configuraton./) }
  end

  context 'raring' do
    let(:facts) do default_facts.merge(
      {
        :os => {
            'name'    => 'Ubuntu',
            'family'  => 'Debian',
            'release' => {
                'major' => '13.04'
            }
        },
        :vmwaretools_version => '9.2.0'
      }
    ) end
    it { is_expected.to raise_error(Puppet::Error, /Ubuntu 13.04 is not supported by this module/) }
  end

  context 'no md5' do
    let (:facts) do default_facts.merge({ :vmwaretools_version => '9.2.0' })  end
    let(:params) {{ :archive_url => 'http://myserver.tld' }}
    it { is_expected.to raise_error(Puppet::Error, /MD5 not given for VMware Tools installer package/) }
  end

  context 'timesync on' do
    let (:facts) do default_facts.merge({ :vmwaretools_version => '9.2.0' })  end
    let(:params) {{ :timesync => true }}
    it { is_expected.to contain_class('vmwaretools::timesync') }
  end

  context 'timesync off' do
    let (:facts) do default_facts.merge({ :vmwaretools_version => '9.2.0' })  end
    let(:params) {{ :timesync => false }}
    it { is_expected.to contain_class('vmwaretools::timesync') }
  end

  context 'fail on non-vmware with virtual => xen' do
    let (:facts) do default_facts.merge({ :virtual => 'xen' }) end
    let(:params) {{ :fail_on_non_vmware => true }}
    it { is_expected.to raise_error(Puppet::Error, /Not a VMware platform./) }
  end

  context 'fail on non-vmware with is_virtual => false' do
    let (:facts) do default_facts.merge({ :is_virtual => false }) end
    let(:params) {{ :fail_on_non_vmware => true }}
    it { is_expected.to raise_error(Puppet::Error, /Not a VMware platform./) }
  end
end
