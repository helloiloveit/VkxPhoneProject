/*
 *  ldap.m
 *  ldapsearch
 *
 *  Created by David Syzdek on 11/2/10.
 *  Copyright 2010 David M. Syzdek. All rights reserved.
 *
 */

#include "ldapTest.h"
#include <stdlib.h>
#include <string.h>
#include <sasl/sasl.h>
#include <Foundation/Foundation.h>
#import "ConstantDefinition.h"

void test_all_ldap(const char * caFile)
{
   int err;
 /*  unsigned u;
   const char * sasl_mechs[] = {"SMB-NTLMv2",
                                "SMB-NT",
                                "MS-CHAPv2",
                                "PPS",
                                "PLAIN",
                                "OTP",
                                "NTLM",
                                "LOGIN",
                                "GSSAPI",
                                "DIGEST-MD5",
                                "CRAM-MD5",
                                "WEBDAV-DIGEST",
                                "DHX",
                                "APOP",
                                NULL};
*/
   if (caFile)
   {
      DebugLog(@"setting ca file...");
      err = ldap_set_option(NULL, LDAP_OPT_X_TLS_CACERTFILE, (void *)caFile);
      if (err != LDAP_SUCCESS)
         DebugLog(@"ldap_set_option(): %s", ldap_err2string(err));
   };

   test_simple_ldap(
      MY_LDAP_VERSION,        // LDAP protocol version
      MY_LDAP_URI,            // LDAP URI
      MY_LDAP_BINDDN,         // LDAP bind DN
      MY_LDAP_BINDPW,         // LDAP bind password
      MY_LDAP_BASEDN,         // LDAP search base DN
      MY_LDAP_FILTER,         // LDAP search filter
      MY_LDAP_SCOPE,          // LDAP search scope
      caFile
   );
/*
   for(u = 0; sasl_mechs[u]; u++)
   {
      test_sasl_ldap(
         MY_LDAP_VERSION,        // LDAP Protocol Version
         MY_LDAP_URI,            // LDAP URI
         MY_SASL_AUTHUSER,       // SASL User
         MY_SASL_REALM,          // SASL Realm
         MY_SASL_PASSWD,         // SASL password
         sasl_mechs[u],          // SASL mechanism
         MY_LDAP_BASEDN,         // LDAP Search Base DN
         MY_LDAP_FILTER,         // LDAP Search Filter
         MY_LDAP_SCOPE,          // LDAP Search Scope
         caFile
      );
   };
 */
/*

*/
   return;
}

int
ldap_simple_bind_s_test( LDAP *ld, LDAP_CONST char *dn, LDAP_CONST char *passwd )
{
	struct berval cred;
    

    
	if ( passwd != NULL ) {
		cred.bv_val = (char *) passwd;
		cred.bv_len = strlen( passwd );
	} else {
		cred.bv_val = "";
		cred.bv_len = 0;
	}
    
	return ldap_sasl_bind_s( ld, dn, LDAP_SASL_SIMPLE, &cred,
                            NULL, NULL, NULL );
}


void test_simple_ldap(int version, const char * ldapURI, const char * bindDN,
   const char * bindPW, const char * baseDN, const char * filter, int scope,
   const char * caFile)
{
   int              i;
   int              err;
   char           * msg;
   char           * attribute;
   LDAP           * ld;
   BerValue         cred;
   BerValue       * servercredp;
   BerElement     * ber;
   const char     * dn;
   LDAPMessage    * res;
   LDAPMessage    * entry;
   struct berval ** vals;

   vals            = NULL;
   servercredp     = NULL;
   dn              = "cn=Directory Manager";

   DebugLog(@"attempting %s bind:", (caFile ? "TLS simple" : "simple"));
   ldapURI = ldapURI ? ldapURI : "ldap://127.0.0.1";
   DebugLog(@"   initialzing LDAP (%s)...", ldapURI);
   err = ldap_initialize(&ld, ldapURI);
   if (err != LDAP_SUCCESS)
   {
      DebugLog(@"   ldap_initialize(): %s\n", ldap_err2string(err));
      return;
   };

   version = version ? version : LDAP_VERSION3;
   DebugLog(@"   setting protocol version %i...", version);
   err = ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, &version);
   if (err != LDAP_SUCCESS)
   {
      DebugLog(@"   ldap_set_option(): %s\n", ldap_err2string(err));
      ldap_unbind_ext_s(ld, NULL, NULL);
      return;
   };

   if (caFile)
   {
     DebugLog(@"   attempting to start TLS...");
      err = ldap_start_tls_s(ld, NULL, NULL);
      if (err == LDAP_SUCCESS)
      {
         DebugLog(@"   TLS established");
      } else {
         ldap_get_option( ld, LDAP_OPT_DIAGNOSTIC_MESSAGE, (void*)&msg);
         DebugLog(@"   ldap_start_tls_s(): %s", ldap_err2string(err));
         DebugLog(@"   ssl/tls: %s", msg);
         ldap_memfree(msg);
      };
   };

   DebugLog(@"   Bind Data:");
   DebugLog(@"      Mech:    Simple");
   DebugLog(@"      DN:      %s", bindDN ? bindDN : "(NULL)");
   DebugLog(@"      Passwd:  %s", bindPW ? bindPW : "(NULL)");

   DebugLog(@"   binding to LDAP server...");
   cred.bv_val = bindPW ? strdup(bindPW) : NULL;
   cred.bv_len = bindPW ? (size_t) strlen("drowssap") : 0;
  // err = ldap_sasl_bind_s(ld, bindDN, LDAP_SASL_SIMPLE, &cred, NULL, NULL, &servercredp);
 //   err = ldap_sasl_bind_s(ld, bindDN, LDAP_SASL_SIMPLE, &cred, NULL, NULL, &servercredp);
     err = ldap_simple_bind_s_test(ld, NULL, NULL);
   if (err != LDAP_SUCCESS)
   {
      DebugLog(@"   ldap_sasl_bind_s(): %s", ldap_err2string(err));
      ldap_unbind_ext_s(ld, NULL, NULL);
      return;
   };

   DebugLog(@"   initiating lookup...");
   //if ((err = ldap_search_ext_s(ld, baseDN, scope, filter, NULL, 0, NULL, NULL, NULL, -1, &res)))
    if ((err = ldap_search_ext_s(ld, "dc=wso3,dc=com", LDAP_SCOPE_SUBTREE, "(sn=*)", NULL, 0, NULL, NULL, NULL,0, &res)))
   {
      DebugLog(@"   ldap_search_ext_s(): %s", ldap_err2string(err));
      ldap_unbind_ext_s(ld, NULL, NULL);
      return;
   };

   DebugLog(@"   checking for results...");
   if (!(ldap_count_entries(ld, res)))
   {
      DebugLog(@"   no entries found.");
      ldap_msgfree(res);
      ldap_unbind_ext_s(ld, NULL, NULL);
      return;
   };
   DebugLog(@"   %i entries found.", ldap_count_entries(ld, res));

   DebugLog(@"   retrieving results...");
   if (!(entry = ldap_first_entry(ld, res)))
   {
      DebugLog(@"   ldap_first_entry(): %s", ldap_err2string(err));
      ldap_msgfree(res);
      ldap_unbind_ext_s(ld, NULL, NULL);
      return;
   };

   while(entry)
   {
      DebugLog(@" ");
      DebugLog(@"      dn: %s", ldap_get_dn(ld, entry));

      attribute = ldap_first_attribute(ld, entry, &ber);
      while(attribute)
      {
         if ((vals = ldap_get_values_len(ld, entry, attribute)))
         {
            for(i = 0; vals[i]; i++)
               DebugLog(@"      %s: %s", attribute, vals[i]->bv_val);
            ldap_value_free_len(vals);
         };
         ldap_memfree(attribute);
         attribute = ldap_next_attribute(ld, entry, ber);
      };

      // skip to the next entry
      entry = ldap_next_entry(ld, entry);
   };
   DebugLog(@" ");

   DebugLog(@"   unbinding from LDAP server...");
   ldap_unbind_ext_s(ld, NULL, NULL);
	
	return;
}

NSArray * get_user_list( int version, const char * ldapURI, const char * bindDN,
                        const char * bindPW, const char * baseDN, const char * filter, int scope,
                        const char * caFile)
{
    int              i;
    int              err;
    char           * msg;
    char           * attribute;
    LDAP           * ld;
    BerValue         cred;
    BerValue       * servercredp;
    BerElement     * ber;
    const char     * dn;
    LDAPMessage    * res;
    LDAPMessage    * entry;
    struct berval ** vals;
    vals            = NULL;
    servercredp     = NULL;
    
    dn              = "cn=Directory Manager";
    
    DebugLog(@"attempting %s bind:", (caFile ? "TLS simple" : "simple"));
    ldapURI = ldapURI ? ldapURI : "ldap://127.0.0.1";
    DebugLog(@"   initialzing LDAP (%s)...", ldapURI);
    err = ldap_initialize(&ld, ldapURI);
    if (err != LDAP_SUCCESS)
    {
        DebugLog(@"   ldap_initialize(): %s\n", ldap_err2string(err));
        return NULL;
    };
    
    version = version ? version : LDAP_VERSION3;
    DebugLog(@"   setting protocol version %i...", version);
    err = ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, &version);
    if (err != LDAP_SUCCESS)
    {
        DebugLog(@"   ldap_set_option(): %s\n", ldap_err2string(err));
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL ;
    };
    
    if (caFile)
    {
        DebugLog(@"   attempting to start TLS...");
        err = ldap_start_tls_s(ld, NULL, NULL);
        if (err == LDAP_SUCCESS)
        {
            DebugLog(@"   TLS established");
        } else {
            ldap_get_option( ld, LDAP_OPT_DIAGNOSTIC_MESSAGE, (void*)&msg);
            DebugLog(@"   ldap_start_tls_s(): %s", ldap_err2string(err));
            DebugLog(@"   ssl/tls: %s", msg);
            ldap_memfree(msg);
        };
    };
    
    DebugLog(@"   Bind Data:");
    DebugLog(@"      Mech:    Simple");
    DebugLog(@"      DN:      %s", bindDN ? bindDN : "(NULL)");
    DebugLog(@"      Passwd:  %s", bindPW ? bindPW : "(NULL)");
    
    DebugLog(@"   binding to LDAP server...");
    cred.bv_val = bindPW ? strdup(bindPW) : NULL;
    cred.bv_len = bindPW ? (size_t) strlen("drowssap") : 0;
    //err = ldap_sasl_bind_s(ld, bindDN, LDAP_SASL_SIMPLE, &cred, NULL, NULL, &servercredp);
    err = ldap_simple_bind_s_test(ld, "Uid=admin,ou=system", bindPW);
    if (err != LDAP_SUCCESS)
    {
        DebugLog(@"   ldap_sasl_bind_s(): %s", ldap_err2string(err));
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL;
    } else {
        DebugLog(@" Success connect");
        
    }
    
    DebugLog(@"   initiating lookup...");
    //if ((err = ldap_search_ext_s(ld, baseDN, scope, filter, NULL, 0, NULL, NULL, NULL, -1, &res)))
    //if ((err = ldap_search_ext_s(ld, baseDN, LDAP_SCOPE_SUBTREE, "(sn=*)", NULL, 0, NULL, NULL, NULL,0, &res)))
    if ((err = ldap_search_ext_s(ld, baseDN, LDAP_SCOPE_SUBTREE, "(sn=*)", NULL, 0, NULL, NULL, NULL,0, &res)))
    {
        DebugLog(@"   ldap_search_ext_s(): %s", ldap_err2string(err));
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL;
    };
    
    DebugLog(@"   checking for results...");
    if (!(ldap_count_entries(ld, res)))
    {
        DebugLog(@"   no entries found.");
        ldap_msgfree(res);
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL;
    };
    DebugLog(@"   %i entries found.", ldap_count_entries(ld, res));
    
    DebugLog(@"   retrieving results...");
    if (!(entry = ldap_first_entry(ld, res)))
    {
        DebugLog(@"   ldap_first_entry(): %s", ldap_err2string(err));
        ldap_msgfree(res);
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL;
    };
    
    NSMutableArray * user_list = [NSMutableArray array];
    //  NSMutableDictionary *user_dict = [NSMutableDictionary dictionary];
    while(entry)
    {
        DebugLog(@" ");
        DebugLog(@"      dn: %s", ldap_get_dn(ld, entry));
        NSMutableDictionary *user_dict = [NSMutableDictionary dictionary];
        
        NSString* data_str = [NSString stringWithFormat:@"%s" , ldap_get_dn(ld, entry)];
        [user_dict setObject:data_str forKey:@"dn"];
        
        attribute = ldap_first_attribute(ld, entry, &ber);
        while(attribute)
        {
            if (!strcmp(attribute, "cn")  ) {
                DebugLog(@"cn here");
                if ((vals = ldap_get_values_len(ld, entry, attribute)))
                {
                    
                    
                    for(i = 0; vals[i]; i++){
                        NSString* data_str = [NSString stringWithFormat:@"%s" , vals[i]->bv_val];
                        //[ou_list addObject:data_str];
                        [user_dict setObject:data_str forKey:@"cn"];
                        // DebugLog(@"ou_list = %@",ou_list);
                        
                        
                    }
                    ldap_value_free_len(vals);
                };
                ldap_memfree(attribute);
                attribute = ldap_next_attribute(ld, entry, ber);
            }
            else if(!strcmp(attribute, "uid")){
                DebugLog(@"uid here");
                if ((vals = ldap_get_values_len(ld, entry, attribute)))
                {
                    
                    
                    for(i = 0; vals[i]; i++){
                        NSString* data_str = [NSString stringWithFormat:@"%s" , vals[i]->bv_val];
                        //[ou_list addObject:data_str];
                        [user_dict setObject:data_str forKey:@"uid"];
                        // DebugLog(@"ou_list = %@",ou_list);
                        
                        
                    }
                    ldap_value_free_len(vals);
                };
                ldap_memfree(attribute);
                attribute = ldap_next_attribute(ld, entry, ber);
            } else if(!strcmp(attribute, "departmentNumber")){
                DebugLog(@"department number ");
                if ((vals = ldap_get_values_len(ld, entry, attribute)))
                {
                    
                    
                    for(i = 0; vals[i]; i++){
                        NSString* data_str = [NSString stringWithFormat:@"%s" , vals[i]->bv_val];
                        //[ou_list addObject:data_str];
                        [user_dict setObject:data_str forKey:@"departmentNumber"];
                        // DebugLog(@"ou_list = %@",ou_list);
                        
                        
                    }
                    ldap_value_free_len(vals);
                };
                ldap_memfree(attribute);
                attribute = ldap_next_attribute(ld, entry, ber);
            } else if(!strcmp(attribute, "mail")){
                DebugLog(@"mail ");
                if ((vals = ldap_get_values_len(ld, entry, attribute)))
                {
                    
                    
                    for(i = 0; vals[i]; i++){
                        NSString* data_str = [NSString stringWithFormat:@"%s" , vals[i]->bv_val];
                        //[ou_list addObject:data_str];
                        [user_dict setObject:data_str forKey:@"mail"];
                        // DebugLog(@"ou_list = %@",ou_list);
                        
                        
                    }
                    ldap_value_free_len(vals);
                };
                ldap_memfree(attribute);
                attribute = ldap_next_attribute(ld, entry, ber);
            }else {
                
                if ((vals = ldap_get_values_len(ld, entry, attribute)))
                {
                    for(i = 0; vals[i]; i++){
                        DebugLog(@"      %s: %s", attribute, vals[i]->bv_val);
                    }
                    ldap_value_free_len(vals);
                };
                ldap_memfree(attribute);
                attribute = ldap_next_attribute(ld, entry, ber);
            }
        };
        
        // skip to the next entry
        entry = ldap_next_entry(ld, entry);
        [user_list addObject:user_dict];
        //DebugLog(@"user_list = %@",user_list);
    };
    DebugLog(@" ");
    
    DebugLog(@"   unbinding from LDAP server...");
    ldap_unbind_ext_s(ld, NULL, NULL);
	
	return user_list;
}

NSArray * get_ou_list( int version, const char * ldapURI, const char * bindDN,
                      const char * bindPW, const char * baseDN, const char * filter, int scope,
                      const char * caFile)
{
    int              i;
    int              err;
    char           * msg;
    char           * attribute;
    LDAP           * ld;
    BerValue         cred;
    BerValue       * servercredp;
    BerElement     * ber;
    const char     * dn;
    LDAPMessage    * res;
    LDAPMessage    * entry;
    struct berval ** vals;
    vals            = NULL;
    servercredp     = NULL;
    dn              = "cn=Directory Manager";
    
    InfoLog(@"attempting %s bind:", (caFile ? "TLS simple" : "simple"));
    ldapURI = ldapURI ? ldapURI : "ldap://127.0.0.1";
    DebugLog(@"   initialzing LDAP (%s)...", ldapURI);
    err = ldap_initialize(&ld, ldapURI);
    if (err != LDAP_SUCCESS)
    {
        DebugLog(@"   ldap_initialize(): %s\n", ldap_err2string(err));
        return NULL;
    };
    
    version = version ? version : LDAP_VERSION3;
    DebugLog(@"   setting protocol version %i...", version);
    err = ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, &version);
    if (err != LDAP_SUCCESS)
    {
        DebugLog(@"   ldap_set_option(): %s\n", ldap_err2string(err));
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL ;
    };
    
    if (caFile)
    {
        DebugLog(@"   attempting to start TLS...");
        err = ldap_start_tls_s(ld, NULL, NULL);
        if (err == LDAP_SUCCESS)
        {
            DebugLog(@"   TLS established");
        } else {
            ldap_get_option( ld, LDAP_OPT_DIAGNOSTIC_MESSAGE, (void*)&msg);
            DebugLog(@"   ldap_start_tls_s(): %s", ldap_err2string(err));
            DebugLog(@"   ssl/tls: %s", msg);
            ldap_memfree(msg);
        };
    };
    
    DebugLog(@"   Bind Data:");
    DebugLog(@"      Mech:    Simple");
    DebugLog(@"      DN:      %s", bindDN ? bindDN : "(NULL)");
    DebugLog(@"      Passwd:  %s", bindPW ? bindPW : "(NULL)");
    
    DebugLog(@"   binding to LDAP server...");
    cred.bv_val = bindPW ? strdup(bindPW) : NULL;
    cred.bv_len = bindPW ? (size_t) strlen("drowssap") : 0;
    //err = ldap_sasl_bind_s(ld, bindDN, LDAP_SASL_SIMPLE, &cred, NULL, NULL, &servercredp);
    // err = ldap_simple_bind_s(ld, NULL, NULL);
    err = ldap_simple_bind_s_test(ld, "Uid=admin,ou=system", bindPW);
    if (err != LDAP_SUCCESS)
    {
        InfoLog(@"   ldap_sasl_bind_s(): %s", ldap_err2string(err));
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL;
    } else {
        InfoLog(@" Success connect");
        
    }
    
    DebugLog(@"   initiating lookup...");
    //if ((err = ldap_search_ext_s(ld, baseDN, scope, filter, NULL, 0, NULL, NULL, NULL, -1, &res)))
    //if ((err = ldap_search_ext_s(ld, bindDN, LDAP_SCOPE_SUBTREE, "(&(objectclass=organizationalunit))", NULL, 0, NULL, NULL, NULL,0, &res)))
    DebugLog(@"baseDN = %s", baseDN);
    if ((err = ldap_search_ext_s(ld, baseDN , LDAP_SCOPE_SUBTREE, "(&(objectclass=organizationalunit))", NULL, 0, NULL, NULL, NULL,0, &res)))
    {
        DebugLog(@"   ldap_search_ext_s(): %s", ldap_err2string(err));
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL;
    };
    
    DebugLog(@"   checking for results...");
    if (!(ldap_count_entries(ld, res)))
    {
        DebugLog(@"   no entries found.");
        ldap_msgfree(res);
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL;
    };
    DebugLog(@"   %i entries found.", ldap_count_entries(ld, res));
    
    DebugLog(@"   retrieving results...");
    if (!(entry = ldap_first_entry(ld, res)))
    {
        DebugLog(@"   ldap_first_entry(): %s", ldap_err2string(err));
        ldap_msgfree(res);
        ldap_unbind_ext_s(ld, NULL, NULL);
        return NULL;
    };
    
    NSMutableArray * ou_list = [NSMutableArray array];
    
    while(entry)
    {
        DebugLog(@" ");
        DebugLog(@"      dn: %s", ldap_get_dn(ld, entry));
        
        attribute = ldap_first_attribute(ld, entry, &ber);
        while(attribute)
        {
            if (!strcmp(attribute, "ou")) {
                
                if ((vals = ldap_get_values_len(ld, entry, attribute)))
                {
                    
                    
                    for(i = 0; vals[i]; i++){
                        NSString* data_str = [NSString stringWithFormat:@"%s" , vals[i]->bv_val];
                        /*
                         if (strcmp(vals[i]->bv_val, "Users")) {
                         [ou_list addObject:data_str];
                         }*/
                        const char *myChar = "Users";
                        if (![data_str isEqualToString:[NSString stringWithUTF8String:myChar]]) {
                             [ou_list addObject:data_str];
                        }

                       // [ou_list addObject:data_str];
                        
                        DebugLog(@"ou_list = %@",ou_list);
                        
                        
                    }
                    ldap_value_free_len(vals);
                };
                ldap_memfree(attribute);
                attribute = ldap_next_attribute(ld, entry, ber);
            } else {
                
                if ((vals = ldap_get_values_len(ld, entry, attribute)))
                {
                    for(i = 0; vals[i]; i++){
                        DebugLog(@"      %s: %s", attribute, vals[i]->bv_val);
                    }
                    ldap_value_free_len(vals);
                };
                ldap_memfree(attribute);
                attribute = ldap_next_attribute(ld, entry, ber);
            }
        };
        
        // skip to the next entry
        entry = ldap_next_entry(ld, entry);
    };
    DebugLog(@" ");
    
    DebugLog(@"   unbinding from LDAP server...");
    ldap_unbind_ext_s(ld, NULL, NULL);
	
	return ou_list;
}

NSArray * get_data_from_server(const char * caFile)
{

    NSArray *temp;
    float i=0;
    NSString * dn_init = @"ou=Users,dc=example,dc=com";
    temp = get_ou_list(
                       MY_LDAP_VERSION,        // LDAP protocol version
                       MY_LDAP_URI,            // LDAP URI
                       MY_LDAP_BINDDN,         // LDAP bind DN
                       MY_LDAP_BINDPW,         // LDAP bind password
                       [dn_init UTF8String],         // LDAP search base DN
                       MY_LDAP_FILTER,         // LDAP search filter
                       MY_LDAP_SCOPE,          // LDAP search scope
                       caFile
                       );
    DebugLog(@"List of Ou = %@", temp);
    
    
    
    //get user
    NSMutableArray *result_array = [NSMutableArray array];
    
    
    for(i=0;i<([temp count] -1);i++)
    {
        NSString * ou_str = [temp objectAtIndex:i ];
        //DebugLog(@"ou_str = %@",ou_str);
        NSString * dn_str = [[NSString alloc] initWithFormat:@"ou=%@,ou=Users,dc=example,dc=com" ,ou_str];
        DebugLog(@"Get Dn = %@", dn_str);
        NSArray * user_info = get_user_list(
                                            MY_LDAP_VERSION,        // LDAP protocol version
                                            MY_LDAP_URI,            // LDAP URI
                                            MY_LDAP_BINDDN,         // LDAP bind DN
                                            MY_LDAP_BINDPW,         // LDAP bind password
                                            [dn_str UTF8String],     // LDAP search base DN
                                            MY_LDAP_FILTER,         // LDAP search filter
                                            MY_LDAP_SCOPE,          // LDAP search scope
                                            caFile
                                            );
        NSMutableDictionary *user_dict = [NSMutableDictionary dictionary];
        [user_dict setObject:user_info forKey:ou_str];
        [result_array addObject:user_dict];
    }
    DebugLog(@"result_array = %@", result_array );
    return result_array;
}

