<?php

/**
 * SQL数据库配置信息
 * 多库
 * version
 */
 $GLOBALS['arr'] = [
     //堂食OC

    'eat_oc_db_connect'=>[
        'db_host'=>'<%= @host %>',
        'db_name'=>'<%= @username %>',
        'db_pass'=>''<%= @password %>',
        'db_database'=>'syncedoc',
     ],
     //外卖oc

     'takeout_oc_db_connect'=>[
        'db_host'=>'<%= @host %>',
        'db_name'=>'<%= @username %>',
        'db_pass'=>''<%= @password %>',
        'db_database'=>'gfsoc',
     ],

     //ERP

    'erp_db_connect'=>[
        'db_host'=>'<%= @host %>',
        'db_name'=>'<%= @username %>',
        'db_pass'=>''<%= @password %>',
        'db_database'=>'erp',
    ],

     //本地服务器DB 用于多库联查
     'loc_db_connect'=>[
        'db_host'=>'<%= @host %>',
        'db_name'=>'<%= @username %>',
        'db_pass'=>''<%= @password %>',
        'db_database'=>'oc',
     ],

];


/**
 * 设置多库联查的库名称
 */
$GLOBALS['dbname'] =[
    'oc'=>'oc',      //设置oc的数据库名称
    'erp'=>'erp',              //设置erp的数据库名称
    'laravel'=> 'laravel',
    'de'=>'de',
    'crm'=>'crm'
];

