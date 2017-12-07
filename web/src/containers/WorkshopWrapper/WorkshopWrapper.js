import React, { Component } from 'react'
import Radium from 'radium'
import Helmet from 'react-helmet'
import Axios from 'axios'

import config from 'config'
import { mediaQueries } from 'styles/common'
import { LoadingSpinner, NavBar } from 'components'
import { NotFound } from 'components'

import Workshop from './Workshop/Workshop'
import ExportButtons from './ExportButtons'

const baseUrl = config.apiBaseUrl + '/v1/repo/workshops/'

const styles = {
  pageWrapper: {
    height: '100%'
  },
  workshopWrapper: {
    margin: '10px auto',
    height: '100%',
    padding: '1em',
    [mediaQueries.mediumUp]: {
      maxWidth: '75%',
      width: '750px'
    }
  }
}

class WorkshopWrapper extends Component {
  constructor(props) {
    super(props)

    const rootUrl = baseUrl + 'README.md'
    const extendedUrl = baseUrl + props.routeParams.splat
    const url = props.routeParams.splat ? extendedUrl : rootUrl

    this.titleizedName = this.titleize(props.routeParams.splat)

    this.requestWorkshop(url)
  }

  titleize(str) {
    return str
      .replace(/[^-_a-zA-Z0-9]+/g, '')
      .split('_')
      .map(txt => {
        return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
      })
      .join(' ')
  }

  requestWorkshop(url) {
    Axios.get(url)
      .then(resp => this.placeWorkshop(resp.data, url))
      .catch(e => this.handleError(e, url))
  }

  placeWorkshop(data, url) {
    this.setState({
      notFound: false,
      markdown: data,
      assetsUrl: url
    })
  }

  handleError(e, url) {
    const isNotFound = e.request && e.request.status === 404
    const isNotReadme = !/README.md$/.test(url)

    if (isNotFound && isNotReadme) {
      url = `${url}/README.md`

      this.requestWorkshop(url)
    } else {
      this.setState({
        notFound: true
      })
    }
  }

  getInitialState() {
    return {
      notFound: null
    }
  }

  content() {
    const { notFound, markdown, assetsUrl } = this.state
    const { location } = this.props

    if (notFound === true) {
      return <NotFound />
    } else if (notFound === false) {
      return (
        <div>
          <Workshop
            markdown={markdown}
            imagesUrl={assetsUrl}
            location={location}
          />
          <ExportButtons
            titleizedName={this.titleizedName}
            pdfDownloadHref={assetsUrl.replace('.md', '.pdf')}
          />
        </div>
      )
    } else {
      return <LoadingSpinner />
    }
  }

  render() {
    return (
      <div style={styles.pageWrapper}>
        <Helmet title={this.titleizedName || 'Workshops'} />
        <NavBar />
        <div style={styles.workshopWrapper}>{this.content()}</div>
      </div>
    )
  }
}

export default Radium(WorkshopWrapper)
