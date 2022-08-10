import { lazy, Suspense } from 'react'
import { Linear as Loading } from '../../../components/loading'
import {
  Home,
  Contract,
  Map,
  About,
  Github,
  License,
  Link,
  ChartTimelineVariantShimmer,
} from '../../../components/icons'
import HomePage from './home'

const PrivacyPolicyPage = lazy(() => import('../../../modules/privacy-policy'))
const AboutPage = lazy(() => import('../../../modules/about'))
const VisualizationsPage = lazy(() => import('./visualizations'))
const EsriPage = lazy(() => import('../../esri-atlas/ssr'))

const L = () => <Loading sx={{ width: '100%' }} />

export default [
  {
    to: '/',
    path: '*',
    label: 'Home',
    Icon: Home,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => <HomePage {...props} />,
  },

  {
    to: '/visualizations/:id',
    path: '/visualizations/:id',
    label: 'Model',
    Icon: ChartTimelineVariantShimmer,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => (
      <Suspense fallback={<L />}>
        <EsriPage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/visualizations',
    path: '/visualizations',
    label: 'Visualisations',
    Icon: Map,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => (
      <Suspense fallback={<L />}>
        <VisualizationsPage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/about',
    path: '/about',
    label: 'About',
    Icon: About,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => (
      <Suspense fallback={<L />}>
        <AboutPage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/privacy-policy',
    path: '/privacy-policy',
    label: 'Privacy policy',
    group: 'legal',
    includeInFooter: true,
    includeInNavMenu: false,
    Icon: Contract,
    element: props => (
      <Suspense fallback={<L />}>
        <PrivacyPolicyPage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/no-route', // Hack - the to property is still required
    group: 'source code',
    label: 'Source code',
    Icon: Github,
    href: 'https://github.com/SAEON/somisana',
    includeInNavMenu: false,
    includeInFooter: true,
  },
  {
    to: '/no-route', // Hack - the to property is still required
    group: 'source code',
    label: 'License (MIT)',
    Icon: License,
    includeInNavMenu: false,
    includeInFooter: true,
    href: 'https://github.com/SAEON/somisana/blob/stable/LICENSE',
  },

  {
    to: '/no-route', // Hack - the to property is still required
    group: 'source code',
    label: 'flagpedia.net',
    Icon: Link,
    includeInNavMenu: false,
    includeInFooter: true,
    href: 'https://flagpedia.net',
  },
]
