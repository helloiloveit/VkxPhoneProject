/*
 *  ldap.h
 *  ldapsearch
 *
 *  Created by David Syzdek on 11/2/10.
 *  Copyright 2010 David M. Syzdek. All rights reserved.
 *
 */
#include <ldap.h>

#define MY_LDAP_VERSION    LDAP_VERSION3
//#define MY_LDAP_URI        "ldap://localhost/"
#define MY_LDAP_URI        "ldap://124.46.127.73/"
//#define MY_LDAP_BINDDN     "cn= admin, dc=wso3,dc=com"
#define MY_LDAP_BINDDN     "Dc= Example, dc=0"
//#define MY_LDAP_BINDPW     "maiphuong"
#define MY_LDAP_BINDPW     "secret"
#define MY_LDAP_BASEDN     "o=test"
#define MY_LDAP_FILTER     "(o=*)"
#define MY_LDAP_SCOPE      LDAP_SCOPE_SUB

#define MY_SASL_AUTHUSER   "test"
#define MY_SASL_REALM      NULL
#define MY_SASL_PASSWD     MY_LDAP_BINDPW
#define MY_SASL_MECH       "DIGEST-MD5"

typedef struct my_ldap_auth MyLDAPAuth;
struct my_ldap_auth
{
   char * mech;
   char * authuser;
   char * user;
   char * realm;
   char * passwd;
};

NSArray * get_data_from_server(const char * caFile);

void test_all_ldap(const char * caFile);

void test_simple_ldap(int version, const char * ldapURI, const char * bindDN,
   const char * bindPW, const char * baseDN, const char * filter, int scope,
   const char * caFile);

void test_sasl_ldap(int version, const char * ldapURI, const char * user,
   const char * realm, const char * pass, const char * mech,
   const char * baseDN, const char * filter, int scope, const char * caFile);

int ldap_sasl_interact(LDAP *ld, unsigned flags, void *defaults,
   void *sasl_interact);
