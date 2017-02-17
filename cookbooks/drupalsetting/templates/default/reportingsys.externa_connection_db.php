<?php

/**
 * SQL数据库配置信息
 * 多库
 * version
 */
 $GLOBALS['arr'] = [
     //堂食OC

    'eat_oc_db_connect'=>[
        'db_host'=>'sm12g5l9d32eyun.cjwa2zciaejp.rds.cn-north-1.amazonaws.com.cn',
        'db_name'=>'keithyau',
        'db_pass'=>'thomas123',
        'db_database'=>'syncedoc',
     ],
     //外卖oc

     'takeout_oc_db_connect'=>[
         'db_host'=>'sm12g5l9d32eyun.cjwa2zciaejp.rds.cn-north-1.amazonaws.com.cn',
         'db_name'=>'keithyau',
         'db_pass'=>'thomas123',
         'db_database'=>'syncedoc',
     ],

     //ERP

    'erp_db_connect'=>[
        'db_host'=>'sm12g5l9d32eyun.cjwa2zciaejp.rds.cn-north-1.amazonaws.com.cn',
        'db_name'=>'keithyau',
        'db_pass'=>'thomas123',
        'db_database'=>'erp',
    ],

     //本地服务器DB 用于多库联查
     'loc_db_connect'=>[
         'db_host'=>'sm12g5l9d32eyun.cjwa2zciaejp.rds.cn-north-1.amazonaws.com.cn',
         'db_name'=>'keithyau',
         'db_pass'=>'thomas123',
         'db_database'=>'syncedoc',
     ],

     //更新门店用到的数据库
     'datastore_db_connect'=>[
         'db_host'=>'sm12g5l9d32eyun.cjwa2zciaejp.rds.cn-north-1.amazonaws.com.cn',
         'db_name'=>'keithyau',
         'db_pass'=>'thomas123',
         'db_database'=>'laravel',
     ],
];


/**
 * 设置多库联查的库名称
 */
$GLOBALS['dbname'] =[
    'oc'=>'syncedoc',      //设置oc的数据库名称
    'erp'=>'erp',              //设置erp的数据库名称
    'laravel'=> 'laravel',
    'de'=>'de',
    'crm'=>'crm'
];

