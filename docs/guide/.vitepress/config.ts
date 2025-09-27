import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: '紫紺祭投票アプリ',
  description: '紫紺祭投票アプリの使用方法ガイド',
  lang: 'ja-JP',
  
  // GitHub Pages用のbase設定
  base: '/guide/',
  
  head: [
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    [
      'link',
      {
        rel: 'stylesheet',
        href:
          'https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&display=swap'
      }
    ]
  ],
  
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'ホーム', link: '/' },
      { text: 'インストール', link: '/installation' },
      { text: '設定変更', link: '/change-config' },
      { text: '公開', link: '/build' }
    ],

    sidebar: [
      {
        text: 'はじめに',
        items: [
          { text: '概要', link: '/about' },
          { text: '始める前に', link: '/getting-started' }
        ]
      },
      {
        text: 'セットアップ',
        items: [
          { text: 'インストール', link: '/installation' },
          { text: '設定変更', link: '/change-config' },
          { text: 'クローン', link: '/clone' }
        ]
      },
      {
        text: '公開',
        items: [
          { text: '公開する', link: '/build' }
        ]
      },
      {
        text: '参考',
        items: [
          { text: 'Markdown例', link: '/markdown-examples' },
          { text: 'API例', link: '/api-examples' },
          { text: '仕様', link: '/specification' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/Shikon-voteapp/Shikon-voteapp.github.io' }
    ],
    
    // 日本語設定
    search: {
      provider: 'local',
      options: {
        translations: {
          button: {
            buttonText: '検索',
            buttonAriaLabel: '検索'
          },
          modal: {
            noResultsText: '該当する結果がありません',
            resetButtonTitle: 'リセット',
            footer: {
              selectText: '選択',
              navigateText: '移動',
              closeText: '閉じる'
            }
          }
        }
      }
    },
    
    // フッター設定
    footer: {
      message: '紫紺祭投票アプリガイド',
      copyright: 'Copyright © 2024 紫紺祭投票アプリ'
    }
  }
})



