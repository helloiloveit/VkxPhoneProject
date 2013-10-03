# -*- rpm-spec -*-
# 
# msilbc - iLBC codec plugin for mediastreamer2
# 

Summary:	iLBC codec plugin for mediastreamer2
Name:		msilbc
Version:	2.1.0
Release:	1
License:	GPL
Group:		Applications/Communications
URL:		http://www.belledonne-communications.com
Source0:	%{name}-2.1.0.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-buildroot
%ifarch %ix86
BuildArch:	i686
%endif
Requires: bash >= 2.0

%description
iLBC codec plugin for mediastreamer2.

%prep
%setup -q

%build
%configure 
%{__make} 

# parallel build disabled due to automake libtool random errors
#%{__make} -j$RPM_BUILD_NCPUS 

%install
rm -rf $RPM_BUILD_ROOT
%makeinstall

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc AUTHORS COPYING ChangeLog INSTALL NEWS README
%{_libdir}/*


%changelog
* Thu Oct 6 2011 Simon Morlat <simon.morlat@belledonne-communications.com>
	- Initial specfile.

